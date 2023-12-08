### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ a1c5360a-de7d-4b8d-907f-025872b5c4d3
import Pkg; Pkg.add("Plots")

# ╔═╡ fc3805ee-3452-4a4e-b04e-a3506ee7d4d0
Pkg.add("CSV")

# ╔═╡ db32ff8b-5243-4473-a272-e111b5f94b90
Pkg.add("DataFrames")

# ╔═╡ b389407b-1272-4958-adc1-f709609198b1
Pkg.add("Statistics")

# ╔═╡ a7c64d5d-f296-4713-8e0a-8a1d3ad144b5
Pkg.add("PyPlot")

# ╔═╡ 146c4c54-1d5a-43a7-bca2-aefde08b1d3d
Pkg.add("RDatasets")

# ╔═╡ 0f952692-1fb2-4214-ab90-beda3531a5f5
Pkg.add("StatsPlots")

# ╔═╡ 9ec6cada-680a-4d7a-9734-254a8977657b
Pkg.add("Interact")

# ╔═╡ 26f316b5-50d5-44de-861c-065f4e39b3d6
Pkg.add("Blink")

# ╔═╡ 4834d0e2-9325-4d4a-aa54-274f7100e669
Pkg.add("Distributions")


# ╔═╡ 6774659c-4017-4834-8c60-8db345f125fe
Pkg.add("FreqTables")

# ╔═╡ 8b776a2d-23fa-473b-85d0-8f5a763e6831
Pkg.add("AverageShiftedHistograms")

# ╔═╡ 4197ab47-8622-4ebf-99c1-a350ed6cf7ca
using CSV

# ╔═╡ 530a90c9-4972-44e5-812e-7dbd610bb6da
using DataFrames

# ╔═╡ 1a1251f3-86bd-43c1-b1c4-17ceae07f125
using Statistics

# ╔═╡ 0d59739e-aea8-470c-b72e-35aa5ff49669
using Plots

# ╔═╡ 0baeed24-ebba-4ad5-8da1-747ca34313d4
using Distributions

# ╔═╡ 29778b4a-5df5-42e6-8e55-439f48867221
using FreqTables

# ╔═╡ 4e1da832-75b9-4e29-be30-83ae2fbd5cdd
using StatsPlots 

# ╔═╡ fdc1a8f6-8161-11ee-1711-5f68fb1ab9af
println("Hello world!")

# ╔═╡ f8b4d041-e2f5-4980-8671-e9d3d18a499b
data = CSV.File("spotify_data.csv") |> DataFrame

# ╔═╡ 537bbae1-2db9-4546-9782-5639ba41ea15
data

# ╔═╡ 053590c2-342a-495e-90ee-518444c3bcdf
# Mostrar información general sobre el DataFrame
println("Información general sobre el conjunto de datos:")

# ╔═╡ 530c3960-aec4-4148-a83f-f61ac035fa75
show(summary(data))

# ╔═╡ 314a2519-5295-487b-9672-c10d941b4df5
# Shape of Dataset
size(data)

# ╔═╡ cfdb321b-ecfd-4993-a695-ab4e78ceb68a
describe(data)

# ╔═╡ 54ad93b1-a42f-41eb-a56f-819ffc592222
# Plot Histogram
Plots.histogram(data[!,"year"], 
                bins = 50, ylim = (10000,70000), xlabel = "year", 
                            labels = "Song amount")

# ╔═╡ 836cda21-a11e-4faf-979c-ac316e1a71b6
#Top 100 canciones
df_sorted_top_100_canciones_mas_populares = first(sort(data,:popularity, rev=true),100)

# ╔═╡ bb8004c0-eda4-4657-b737-9d10ca274a75
#parece que las mas populares tienden a ser mas danzables
scatter(df_sorted_top_100_canciones_mas_populares.danceability, df_sorted_top_100_canciones_mas_populares.popularity, label="Popularidad", xlabel="Danzabilidad", ylabel="Popularidad", legend=:topright)

# ╔═╡ dd2c83d3-a238-464e-bbff-a90d136d6fa2
#Top 100 canciones mas danzables
df_sorted_top_100_canciones_mas_danzables = first(sort(data,:danceability, rev=true),100)

# ╔═╡ 76da5f1c-19ef-4db9-912c-a8ad84aaf8d5
#parece que las mas populares tienden a ser mas danzables
scatter(df_sorted_top_100_canciones_mas_danzables.danceability, df_sorted_top_100_canciones_mas_danzables.popularity, label="Popularidad", xlabel="Danzabilidad", ylabel="Popularidad", legend=:topright)

# ╔═╡ e2a8e826-fc2e-44a5-babb-270aff8ef920
#Top 100 canciones mas danzables
df_filtrado_por_128_bpm = df_filtrado = data[(128 .<= data.tempo .< 129), :]

# ╔═╡ 419eaa4a-8771-4b70-a574-5a56d600b091
scatter(df_filtrado_por_128_bpm.tempo, df_filtrado_por_128_bpm.popularity, label="Tempo", xlabel="Tempo", ylabel="Popularidad", legend=:topright)

# ╔═╡ b6a94f34-ff7a-480b-87a1-e3013fab986d
#Queria ver el comportamiento general de las canciones haciendo Tempo y Popularidad
scatter(data.tempo, df_filtrado_por_128_bpm.popularity, label="Popularidad", xlabel="Tempo", ylabel="Popularidad", legend=:topright)

# ╔═╡ 4dcb97a6-b713-485b-85eb-74ea072b0520
df_agrupado_por_anio = groupby(data,:year)

# ╔═╡ 0b0b8a37-c743-47f9-ba80-73f688fd9291
#Parece que el by se deprecó entonces hay que usar el combine indicando las operaciones de cada columna
data_promedio_general_cada_columna_numerica_por_anio_rompe = by(data, :year) do subgrupo
    DataFrame(mean.(eachcol(subgrupo[:, Not(:year)])))
end

# ╔═╡ ee3b365d-13a4-4906-8fe3-eb64befce6c3
begin
	data_promedio_general_cada_columna_numerica_por_anio = combine(groupby(data, :year)) do subgrupo
	    DataFrame(
	        promedio_popularity = mean(subgrupo.popularity),
	        promedio_danceability = mean(subgrupo.danceability),
			promedio_energy = mean(subgrupo.energy),
			promedio_duration_ms = mean(subgrupo.duration_ms)
	    )
	end
end

# ╔═╡ 42feb211-6da7-4570-b0d2-aa1fbd3fd311
begin

	# Calcula la media y la desviación estándar a partir de los datos del DataFrame
	media = mean(data.year)
	desviacion_estandar = std(data.year)
	
	# Crea una distribución normal utilizando la media y la desviación estándar calculadas
	dist_normal = Normal(media, desviacion_estandar)
	
	# Crea un rango de valores para x
	x = Vector{Float64}(collect(minimum(data.year):0.1:maximum(data.year)))
	
	# Calcula los valores de la función de densidad de probabilidad (PDF) de la distribución normal
	y = pdf(dist_normal, x)
	
	# Crea el gráfico de la distribución normal
	plot(x, y, label="Distribución Normal", xlabel="x", ylabel="PDF", linewidth=2)

end 

# ╔═╡ c74df312-7620-4c3f-b44e-86428c5d7850
unique(data[:,:year])

# ╔═╡ 5e95e6c6-5391-4725-a706-325ced198e58
#Agrego una curva de Lorenz solamente para mostrar como funciona un grafico 3D con animación
begin
	# define the Lorenz attractor
	Base.@kwdef mutable struct Lorenz
	    dt::Float64 = 0.02
	    σ::Float64 = 10
	    ρ::Float64 = 28
	    β::Float64 = 8/3
	    x::Float64 = 1
	    y::Float64 = 1
	    z::Float64 = 1
	end
	
	function step!(l::Lorenz)
	    dx = l.σ * (l.y - l.x)
	    dy = l.x * (l.ρ - l.z) - l.y
	    dz = l.x * l.y - l.β * l.z
	    l.x += l.dt * dx
	    l.y += l.dt * dy
	    l.z += l.dt * dz
	end
	
	attractor = Lorenz()
	
	
	# initialize a 3D plot with 1 empty series
	plt = plot3d(
	    1,
	    xlim = (-30, 30),
	    ylim = (-30, 30),
	    zlim = (0, 60),
	    title = "Lorenz Attractor",
	    legend = false,
	    marker = 2,
	)
	
	# build an animated gif by pushing new points to the plot, saving every 10th frame
	@gif for i=1:1500
	    step!(attractor)
	    push!(plt, attractor.x, attractor.y, attractor.z)
	end every 10
end

# ╔═╡ 435028cc-f443-42e8-a456-4a2b58b36954
begin
	o1 = ash(data.danceability)
	plot(o1)
end

# ╔═╡ 7cb098be-6259-42fd-8142-b8264fdc5d04
## Ejemplo rapido de como hacer un heatmap
begin
	gr()
	data_aux = rand(21,100)
	heatmap(1:size(data_aux,1),
	1:size(data_aux,2), data_aux,
	c=cgrad([:blue, :white,:red, :yellow]),
	xlabel="x values", ylabel="y values",
	title="My title")
end

# ╔═╡ a42de771-793c-4743-95c8-b151ddbe6a05
corrplot([data.danceability data.popularity data.energy data.tempo], grid = false, label = ["Danceaibility" "Popularity" "Energy" "Tempo"])

# ╔═╡ b5883c0a-f837-4538-9a75-0cac9a4350d8
#Aca hay que ser cuidadoso con la cantidad de canciones que hay
begin
	data_promedio_general_cada_columna_numerica_por_genero = combine(groupby(data, :genre)) do subgrupo
	    DataFrame(
			cant_canciones = length(subgrupo.genre),
			promedio_popularity = mean(subgrupo.popularity),
	        promedio_danceability = mean(subgrupo.danceability),
			promedio_energy = mean(subgrupo.energy),
			promedio_duration_ms = mean(subgrupo.duration_ms)
	    )
	end
end

# ╔═╡ 0ddff8dd-b178-45ea-9b76-24294b81eba5


# ╔═╡ ac3fcdf3-a78c-4bcf-ab08-c446cf5ff11f
# Plot Histogram
Plots.histogram(data_promedio_general_cada_columna_numerica_por_genero[!,"promedio_popularity"], 
                bins = 50, ylim = (0,15), xlabel = "promedio_popularity", 
                            labels = data_promedio_general_cada_columna_numerica_por_genero[!,"genre"])

# ╔═╡ b5091c02-3abb-4bf9-8635-6b6f581356b0
#=╠═╡
using AverageShiftedHistograms
  ╠═╡ =#

# ╔═╡ 76788a00-5459-4d23-b62e-ff93c0aebb6c
#=╠═╡
begin
	o2 = ash(data.tempo)
	plot(o2)
end
  ╠═╡ =#

# ╔═╡ 8c18b32b-2705-4e64-a081-769645f2ea37
# ╠═╡ disabled = true
#=╠═╡
begin
	o2 = ash(data.energy)
	plot(o2)
end
  ╠═╡ =#

# ╔═╡ 9ae56359-e28f-4bc8-ad4f-8993d60947a7
# ╠═╡ disabled = true
#=╠═╡
begin 
	Pkg.add("AverageShiftedHistograms")

	using AverageShiftedHistograms

	ash(randn(10^6))
end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═fdc1a8f6-8161-11ee-1711-5f68fb1ab9af
# ╠═fc3805ee-3452-4a4e-b04e-a3506ee7d4d0
# ╠═db32ff8b-5243-4473-a272-e111b5f94b90
# ╠═b389407b-1272-4958-adc1-f709609198b1
# ╠═4197ab47-8622-4ebf-99c1-a350ed6cf7ca
# ╠═530a90c9-4972-44e5-812e-7dbd610bb6da
# ╠═1a1251f3-86bd-43c1-b1c4-17ceae07f125
# ╠═f8b4d041-e2f5-4980-8671-e9d3d18a499b
# ╠═537bbae1-2db9-4546-9782-5639ba41ea15
# ╠═053590c2-342a-495e-90ee-518444c3bcdf
# ╠═530c3960-aec4-4148-a83f-f61ac035fa75
# ╠═314a2519-5295-487b-9672-c10d941b4df5
# ╠═cfdb321b-ecfd-4993-a695-ab4e78ceb68a
# ╠═a1c5360a-de7d-4b8d-907f-025872b5c4d3
# ╠═a7c64d5d-f296-4713-8e0a-8a1d3ad144b5
# ╠═0d59739e-aea8-470c-b72e-35aa5ff49669
# ╠═54ad93b1-a42f-41eb-a56f-819ffc592222
# ╠═146c4c54-1d5a-43a7-bca2-aefde08b1d3d
# ╠═0f952692-1fb2-4214-ab90-beda3531a5f5
# ╠═9ec6cada-680a-4d7a-9734-254a8977657b
# ╠═26f316b5-50d5-44de-861c-065f4e39b3d6
# ╠═836cda21-a11e-4faf-979c-ac316e1a71b6
# ╠═bb8004c0-eda4-4657-b737-9d10ca274a75
# ╠═dd2c83d3-a238-464e-bbff-a90d136d6fa2
# ╠═76da5f1c-19ef-4db9-912c-a8ad84aaf8d5
# ╠═e2a8e826-fc2e-44a5-babb-270aff8ef920
# ╠═419eaa4a-8771-4b70-a574-5a56d600b091
# ╠═b6a94f34-ff7a-480b-87a1-e3013fab986d
# ╠═4dcb97a6-b713-485b-85eb-74ea072b0520
# ╠═0b0b8a37-c743-47f9-ba80-73f688fd9291
# ╠═ee3b365d-13a4-4906-8fe3-eb64befce6c3
# ╠═4834d0e2-9325-4d4a-aa54-274f7100e669
# ╠═0baeed24-ebba-4ad5-8da1-747ca34313d4
# ╠═42feb211-6da7-4570-b0d2-aa1fbd3fd311
# ╠═6774659c-4017-4834-8c60-8db345f125fe
# ╠═29778b4a-5df5-42e6-8e55-439f48867221
# ╠═c74df312-7620-4c3f-b44e-86428c5d7850
# ╠═5e95e6c6-5391-4725-a706-325ced198e58
# ╟─9ae56359-e28f-4bc8-ad4f-8993d60947a7
# ╠═8b776a2d-23fa-473b-85d0-8f5a763e6831
# ╠═b5091c02-3abb-4bf9-8635-6b6f581356b0
# ╠═435028cc-f443-42e8-a456-4a2b58b36954
# ╠═8c18b32b-2705-4e64-a081-769645f2ea37
# ╠═76788a00-5459-4d23-b62e-ff93c0aebb6c
# ╠═7cb098be-6259-42fd-8142-b8264fdc5d04
# ╠═4e1da832-75b9-4e29-be30-83ae2fbd5cdd
# ╠═a42de771-793c-4743-95c8-b151ddbe6a05
# ╠═b5883c0a-f837-4538-9a75-0cac9a4350d8
# ╠═0ddff8dd-b178-45ea-9b76-24294b81eba5
# ╠═ac3fcdf3-a78c-4bcf-ab08-c446cf5ff11f
