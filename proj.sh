#!/bin/bash

#---- ARQUIVOS DE APOIO DESENVOLVIDOS PELO SCRIPT ----
#
# Arquivo: proj.txt: Contém informações dos processos em execução atualmente
# Arquivo: update.txt: Contém um valor (1 ou 0) que indica se a tela será atualizada(1) ou não(0)
#
# -----------------------------------------------------

function update_proj(){
	user=$( get_user )

	# salvando informações de processos
	ps aux | sort -rk 9 | tr -s " " | tr -d "<>" >proj.txt

	# Se aplicável, implementa filtro por usuário
	if [ "${user}" != "{START_USER}" ];then
		sed -n -E "/^${user}/p" proj.txt > proj.bkp.txt
		cat proj.bkp.txt > proj.txt
		rm -f proj.bkp.txt
	fi

	# formata para criação de tabela no yad
	echo "$( awk -f projformat.awk < proj.txt )" > proj.txt

	# retorno
	cat proj.txt
}

function refresh_screen(){
	echo -e "\f"
	update_proj
}

function update_screen(){
	while [ -f update.txt ]
	do
		if [ "$(cat update.txt )" -eq 1 ]
		then
			refresh_screen
			sleep ${UPDATE_INTERVAL}
		fi
	done 2> /dev/null
}

function set_update_screen(){
	# ativa: $1 = 1
	# desativa: $1 = 0

	echo "$1" > update.txt
}

function plot_us(){
	echo -e "Process with ID: $3\t$5\t1\t$6\t2" | tr "," "." > usdata.txt

	gnuplot -p < usplot.gpi

	rm -f usdata.txt
}

function kill_proj(){
	pid=$( echo "$1" | tr "|" "\n" | head -1 )

	kill -9 ${pid}
	./$0
}

function get_user(){
	echo "$( awk '$1="users" { print $2 }' run.conf )"
}

function set_user(){
	sed "/user\t.*/c user\t$1" run.conf > run.conf.bkp
	cat run.conf.bkp > run.conf
	rm -f run.conf.bkp
}

function filter_by_user(){
	set_user $( ./setuser.sh )
}

function main(){

	export -f set_update_screen
	export -f plot_us
	export -f set_user
	export -f filter_by_user

	set_update_screen 1

	GUI=$( yad --list                                            \
	--title="Proj - Project "                                    \
	--width=700 --height=700 --center                            \
	--window-icon="icon.ico"                                     \
	--no-escape                                                  \
	--dclick-action="bash -c 'plot_us %s'"                       \
	--grid-lines="both"                                          \
	--column="@fore@"                                            \
	--column="@back@"                                            \
	--column="PID:NUM"                                           \
	--column="User:TEXT"                                         \
	--column="CPU(%):FLT"                                        \
	--column="RAM(%):FLT"                                        \
	--column="VSZ:SZ"                                            \
	--column="RSS:SZ"                                            \
	--column="Start:TEXT"                                        \
	--column="Comand:TEXT"                                       \
	--buttons-layout="center"                                    \
	--button="Stop:bash -c 'set_update_screen 0'"                \
	--button="Start:bash -c 'set_update_screen 1'"               \
	--button="Filter by user:bash -c 'filter_by_user'"           \
	--button="Start process:bash -c './startproj.sh'"            \
	--button="Schedule process:bash -c './schedproj.sh'"         \
	--button="Kill:0" < <( update_screen )&
	)

	# removendo arquivos desnecessários
	rm -f proj.txt update.txt

	# Se a saída da GUI for não vazia, um processo
	# foi especificado para ser morto.
	# Senão, o processo atual será morto
	[ -n "${GUI}" ] && kill_proc "${GUI}" 2> /dev/null

	# retornando ao user padrão
	set_user "${START_USER}"
}


UPDATE_INTERVAL=5
START_USER=$( get_user )

main

