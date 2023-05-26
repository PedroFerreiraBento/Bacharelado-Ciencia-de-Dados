# instalação dos pacotes que iremos utilizar
install.packages("sidrar")
install.packages("dplyr")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("rlang", version="1.1.0")

# agora vamos chamar os pacotes instalados
library(sidrar)
library(dplyr)
library(lubridate)
library(ggplot2)

# Pacote sidrar
# O pacote sidrar que coleta dados do SIDRA, base de dados do IBGE, diretamente para o R. Pacote bem legal para quem precisa trabalhar com as
# pesquisas da instituição, tais como a PNAD Contínua, PME, PMC, Contas Nacionais, etc. Abaixo, coloco um exemplo de capturar dados da PNAD
# Contínua.

# Ocupados/desocupados na Força de trabalho
raw_ocup_e_desocup <- sidrar::get_sidra(api = "/t/6318/n1/all/v/1641/p/all/c629/all")


# Ocupados/desocupados na Força de trabalho
ocup_e_desocup <- raw_ocup_e_desocup |>
  dplyr::select(
    "date"     = 'Trimestre Móvel (Código)',
    "variable" = 'Condição em relação à força de trabalho e condição de ocupação',
    "value"    = 'Valor'
  ) |>
  dplyr::as_tibble()

ocup_e_desocup

ocup_e_desocup <- ocup_e_desocup  |> 
  dplyr::mutate(
    date = lubridate::ym(date),
    variable = dplyr::recode(
      variable,
      "Total"                          = "População total (PIA)",
      "Força de trabalho"              = "Força de trabalho (PEA)",
      "Força de trabalho - ocupada"    = "Ocupados", 
      "Força de trabalho - desocupada" = "Desocupados",
      "Fora da força de trabalho"      = "Fora da força (PNEA)"
    ),
    value = value / 1000 # converter em milhões de pessoas
  )


ocup_e_desocup <- ocup_e_desocup |> 
  dplyr::filter(date > "2020-01-01")


ocup_e_desocup <- ocup_e_desocup |> 
  dplyr::group_by(year = lubridate::year(date), variable) |> 
  dplyr::summarize(mean = mean(value))


# Plotagem dos gráficos
ggplot2::ggplot(ocup_e_desocup, 
                ggplot2::aes(x = year, y = mean, fill = variable))+
  ggplot2::geom_col()+
  ggplot2::facet_wrap(~variable)