# o arquivo passado deve ser um arquivo de atualização
# de processos pré-formatado criado pelo script proj.sh
# na função update_procs() cujas colunas são as mesmas
# retornadas pelo comando ps

BEGIN{
	MAX_RESOURCE_USAGE=5
	MID_RESOURCE_USAGE=1

	MAX_BCK_COLOR="red"
	MID_BCK_COLOR="yellow"
	LOW_BCK_COLOR="green"

	CLEAN_FORE_COLOR="white"
	DARK_FORE_COLOR="black"
}

NR > 1 {
	# %CPU + %RAM
	resource_usage=$3 + $4
	bck_color=LOW_BCK_COLOR
	fore_color=CLEAN_FORE_COLOR

	if (resource_usage >= MAX_RESOURCE_USAGE ){
		bck_color=MAX_BCK_COLOR;
	}
	else if ( resource_usage >= MID_RESOURCE_USAGE ){
		bck_color=MID_BCK_COLOR;
		fore_color=DARK_FORE_COLOR
	}

	print fore_color"\n"bck_color"\n"$2"\n"$1"\n"$3"\n"$4"\n"$5"\n"$6"\n"$9"\n"$11
}
