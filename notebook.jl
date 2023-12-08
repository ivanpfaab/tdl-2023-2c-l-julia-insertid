### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 5adaa470-86b2-4745-a3c1-88510829685f
begin # dependencias
	import Pkg
	Pkg.add("StatsBase")
	Pkg.add("Plots")
	Pkg.add("PyPlot")
	Pkg.add("Interact")
	Pkg.add("RDatasets")
	Pkg.add("Blink")
	Pkg.add("Distributions")
	Pkg.add("FreqTables")
	Pkg.add("AverageShiftedHistograms")
	Pkg.add("Distances")
	using Distributions
	using FreqTables
	using AverageShiftedHistograms
	using StatsPlots
	using Base.Threads
	using DataFrames
	using HTTP, JSON, Base64
	using Pluto
	using DotEnv
	using Random, StatsBase
	using CSV
	using Clustering, Plots, Distances, Statistics
end

# ╔═╡ 67af2076-8097-4365-b976-9baad57c05e2
begin
	using Markdown

	Markdown.parse("""
	# Dependencias
	"""
	)
end

# ╔═╡ 457cf7cd-fb6b-43f5-8eff-9c5b7ef7cf30
Markdown.parse("""
# EDA
"""
)

# ╔═╡ a4ef2dc5-4ab7-45fd-8c11-48622071225b
data = CSV.File("spotify_data.csv") |> DataFrame

# ╔═╡ 29cd8672-dd23-4138-a25a-ed138ba2def7
data

# ╔═╡ f700e47b-e3e3-4eda-9d90-29aa3783025a
# Mostrar información general sobre el DataFrame
println("Información general sobre el conjunto de datos:")

# ╔═╡ 62a4ff13-43bb-4b59-bcbb-2e74cd6ba354
show(summary(data))

# ╔═╡ 4b10d8e9-c9da-4686-a2fb-6fac57bcb745
# Shape of Dataset
size(data)

# ╔═╡ f7632afb-3dbf-4c13-b7ae-1bd56692423d
describe(data)

# ╔═╡ 984ac556-e740-44c0-9cbd-460fce6b89f8
# Plot Histogram
Plots.histogram(data[!,"year"], 
                bins = 50, ylim = (10000,70000), xlabel = "year", 
                            labels = "Song amount")

# ╔═╡ ffe2da34-9230-438c-88f4-801ae8c81b0e
#Top 100 canciones
df_sorted_top_100_canciones_mas_populares = first(sort(data,:popularity, rev=true),100)

# ╔═╡ 2901c05b-42f5-4f81-ba20-b336219afce0
#parece que las mas populares tienden a ser mas danzables
scatter(df_sorted_top_100_canciones_mas_populares.danceability, df_sorted_top_100_canciones_mas_populares.popularity, label="Popularidad", xlabel="Danzabilidad", ylabel="Popularidad", legend=:topright)

# ╔═╡ a199fb94-1803-4094-b44a-e503dd1844d1
#Top 100 canciones mas danzables
df_sorted_top_100_canciones_mas_danzables = first(sort(data,:danceability, rev=true),100)

# ╔═╡ 5a457784-6cb8-44d5-9858-95e2f6ad1e06
#parece que las mas populares tienden a ser mas danzables
scatter(df_sorted_top_100_canciones_mas_danzables.danceability, df_sorted_top_100_canciones_mas_danzables.popularity, label="Popularidad", xlabel="Danzabilidad", ylabel="Popularidad", legend=:topright)

# ╔═╡ ea46b8df-3169-4b8d-a46c-f6a7aca19638
#Top 100 canciones mas danzables
df_filtrado_por_128_bpm = df_filtrado = data[(128 .<= data.tempo .< 129), :]

# ╔═╡ 1ee97f80-8928-4bc5-9bc6-eeaa5f4261dd
scatter(df_filtrado_por_128_bpm.tempo, df_filtrado_por_128_bpm.popularity, label="Tempo", xlabel="Tempo", ylabel="Popularidad", legend=:topright)

# ╔═╡ dc442071-2cf1-4e46-94ed-d4432d9fa35e
#Queria ver el comportamiento general de las canciones haciendo Tempo y Popularidad
scatter(data.tempo, df_filtrado_por_128_bpm.popularity, label="Popularidad", xlabel="Tempo", ylabel="Popularidad", legend=:topright)

# ╔═╡ 8e42c99b-c290-4772-9012-6f3e51d83ac1
df_agrupado_por_anio = groupby(data,:year)

# ╔═╡ fc9d5801-be91-4798-bd00-0799810c46a7
#Parece que el by se deprecó entonces hay que usar el combine indicando las operaciones de cada columna
data_promedio_general_cada_columna_numerica_por_anio_rompe = by(data, :year) do subgrupo
    DataFrame(mean.(eachcol(subgrupo[:, Not(:year)])))
end

# ╔═╡ 88f1ad35-5f30-42a9-88a2-6cace430c25c
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

# ╔═╡ ce8bc685-5f91-4dc6-bde0-9dfecbee6442
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

# ╔═╡ 52bbcc98-8697-4ed3-bcdb-feae1a51d9c6
unique(data[:,:year])

# ╔═╡ 87105d9b-99b2-4285-9cbe-6887f638c615
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

# ╔═╡ e8a021d4-320c-494b-b4bf-23a931e67e16
ash(randn(10^6))

# ╔═╡ 8bf68b8f-1a4b-43f5-a5a9-d5e07adc02d4
begin
	o1 = ash(data.danceability)
	plot(o1)
end

# ╔═╡ d028886c-45a5-4cd3-93e4-f3434f79bbd1
begin
	o2 = ash(data.energy)
	plot(o2)
end

# ╔═╡ 19abc750-cece-4bd2-b8d3-cf5489156560
begin
	o3 = ash(data.tempo)
	plot(o3)
end

# ╔═╡ f7513326-72be-4bf6-b259-891578726b7d
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

# ╔═╡ 43174160-8229-49bb-8c6c-af934cfd9380
corrplot([data.danceability data.popularity data.energy data.tempo], grid = false, label = ["Danceaibility" "Popularity" "Energy" "Tempo"])

# ╔═╡ 5ff846d3-6e92-4eba-9e10-27869fe831ee
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

# ╔═╡ 241a843e-6fb5-4433-b49a-3a8c26b47d68
# Plot Histogram
Plots.histogram(data_promedio_general_cada_columna_numerica_por_genero[!,"promedio_popularity"], 
                bins = 50, ylim = (0,15), xlabel = "promedio_popularity", 
                            labels = data_promedio_general_cada_columna_numerica_por_genero[!,"genre"])

# ╔═╡ 11b398d9-4453-4e4c-9c26-c4dafddad171
Markdown.parse("""
# Definición de API KEY
"""
)

# ╔═╡ adb3da2a-e2d2-41f5-8e54-e89c7db9dd86
begin
	function get_token_req_body_headers(client_id, client_secret, callback_uri)
		token_request_headers = Dict("Content-Type" => "application/x-www-form-urlencoded")
		token_request_body = nothing

		auth_code = nothing
		try
			auth_code = ENV["AUTH_CODE"]
			token_request_body = "grant_type=authorization_code&code=$auth_code&redirect_uri=$callback_uri"
	
			client_credentials = string(client_id, ":", client_secret)
			encoded_client_credentials = base64encode(client_credentials)
			
			token_request_headers["Authorization"] = "Basic $encoded_client_credentials"
		catch e
			token_request_body = "grant_type=client_credentials&client_id=$client_id&client_secret=$client_secret"
		end
	
		return token_request_headers, token_request_body
	end

	function get_api_token(headers, body)
		url = "https://accounts.spotify.com/api/token"
		response = HTTP.request("POST", url, headers, body)
		if response.status == 200
		    result = JSON.parse(String(response.body))
			return result["access_token"]
		else
		    println("Error al obtener el token de acceso de la API de Spotify")
			return nothing
		end
	end
end

# ╔═╡ f728f427-c67c-4536-b51a-ebf020609da8
begin
	run(`python3 authenticate.py`)
	DotEnv.load()
	client_id = ENV["TDL_SPOTIFY_CLIENT_ID"]
	client_secret = ENV["TDL_SPOTIFY_CLIENT_SECRET"]
	callback_uri = ENV["TDL_CALLBACK_URI"]

	token_request_headers, token_request_body =
		get_token_req_body_headers(client_id, client_secret, callback_uri)

	token = get_api_token(token_request_headers, token_request_body)

	COMMON_REQ_HEADERS = Dict(
        "Authorization" => "Bearer $token",
        "Content-Type" => "application/json"
    )

	SPOTIFY_API_URL = "https://api.spotify.com/v1/"
end

# ╔═╡ 3d156acc-d820-41d8-ab04-615b07aa53c3
function api_http_get_request(endpoint)
	url = SPOTIFY_API_URL * endpoint
	response = HTTP.get(url, COMMON_REQ_HEADERS)
	if response.status == 200
		return JSON.parse(String(response.body))
	else
	    println("Error al obtener los datos de $endpoint")
		return nothing
	end
end

# ╔═╡ 47e503b0-b291-4aaf-a174-11103a200354
function get_track_info(track_id)
	return api_http_get_request("tracks/$track_id")
end

# ╔═╡ c7446543-7622-4140-9aae-ed37eceef159
function get_track_audio_features(track_id)
    return api_http_get_request("audio-features/$track_id")
end

# ╔═╡ 5a565a54-ab2c-41d9-931e-1ea835df3b65
function get_favorite_tracks()
	return api_http_get_request("me/top/tracks?limit=50")
end

# ╔═╡ e82495d6-7070-4b79-9a9d-301f1fbebd4b
begin
	favorite_tracks = get_favorite_tracks()
	favorite_tracks_ids = [item["id"] for item in favorite_tracks["items"]]
end

# ╔═╡ 803356ce-9ebc-44c2-b046-a99e1088d662
function encode_ids(ids)
	return join(map(x -> replace(x, "/" => "%2F", "+" => "%2B", " " => "%20"), ids), ",")
end

# ╔═╡ 66f01f4b-7c04-4e5f-adcb-c5514fa0ef05
function get_recommendations(ids)
	return api_http_get_request("recommendations?seed_tracks=$(encode_ids(ids))&limit=100")["tracks"]
end

# ╔═╡ 80212680-af5f-464d-9f28-8e3c526cfce1
begin
	function process_batch(batch_ids)
	    return [track["id"] for track in get_recommendations(batch_ids)]
	end
	
	BATCH_SIZE = 5
	batches = [favorite_tracks_ids[i:min(i+BATCH_SIZE-1, end)] for i in 1:BATCH_SIZE:length(favorite_tracks_ids)]
	
	recommended_tracks = [Threads.@spawn process_batch(batch) for batch in batches]
	recommended_tracks = vcat(fetch.(recommended_tracks)...)
end

# ╔═╡ c5ec84dd-06ac-433f-8e55-72932891bcbe
recommended_tracks

# ╔═╡ ec787a8f-9821-49ba-bae3-3f37c958bb71
unique_recommended_tracks = collect(Set(recommended_tracks))

# ╔═╡ 5e883871-e5b4-41dd-bd0c-3b1299ff62df
begin
	len_recommended_tracks = length(recommended_tracks)
	len_unique_recommended_tracks = length(unique_recommended_tracks)

	n_filtered = len_recommended_tracks - len_unique_recommended_tracks
	
	println("Se filtraron $n_filtered de $len_recommended_tracks canciones. $len_unique_recommended_tracks canciones únicas")
end

# ╔═╡ d67f578e-4ead-42e8-97c5-9c61a0b0fc2f
function get_audio_features_multiple_tracks(ids)
	return api_http_get_request("audio-features?ids=$(encode_ids(ids))")
end

# ╔═╡ ac3fcb59-990a-4128-ba5a-760b89fb3742
tracks_features_dict = get_audio_features_multiple_tracks(favorite_tracks_ids)

# ╔═╡ 33138cfb-bae4-4dfd-a010-860b42d0dcbe
function tracks_features_to_df(dict_array)
	df = DataFrame()
	for track_features in dict_array
    	df = vcat(df, DataFrame(track_features))
	end
	return df
end

# ╔═╡ c98cf96e-8555-4ec0-9f23-70dc13470acc
df_tracks = tracks_features_to_df(tracks_features_dict["audio_features"])

# ╔═╡ 608a4f93-278c-47a7-b45e-97b46c3fc295
names(df_tracks)

# ╔═╡ 37f86c36-6b32-475f-b191-dd17ac334669
select!(df_tracks, Not(["analysis_url", "track_href", "type", "id"]))

# ╔═╡ 7aa537cb-455e-4469-873d-2a9e4cddc109
begin
	recommended_df = DataFrame()
	
	for i in 1:100:length(unique_recommended_tracks)
	    end_idx = min(i + 100 - 1, length(unique_recommended_tracks))
	    batch_tracks = unique_recommended_tracks[i:end_idx]
		features = get_audio_features_multiple_tracks(batch_tracks)
		new_df = tracks_features_to_df(features["audio_features"])
		recommended_df = vcat(recommended_df, new_df)
	end
end

# ╔═╡ 4395cc1e-b5e7-43e2-a439-0d8baa37dbbf
select!(recommended_df, Not(["analysis_url", "track_href", "type", "id", "duration_ms"]))

# ╔═╡ f792b205-2a4f-4244-8530-297eeed068d0
begin
	N_CLUSTERS = 3
	df = select(recommended_df, Not(:uri))
	matrix = Matrix(df)
	dist_matrix = pairwise(Euclidean(), matrix, matrix, dims=1)
	clusters = kmeans(transpose(matrix), N_CLUSTERS)
	recommended_df.cluster = clusters.assignments
end

# ╔═╡ ac35e817-314d-4a98-9cee-32f3361e8920
begin
	c = [:blue, :red, :green]
	scatter(matrix[:, 1], matrix[:, 2], palette=c, color=clusters.assignments, legend=false)
end

# ╔═╡ 4aba3555-2d08-44e8-b3cc-7962f5b42b70
begin
	xt = (1:N_CLUSTERS)
	cluster_counts = combine(groupby(recommended_df, :cluster), nrow)
	bar(
		cluster_counts.cluster,
		cluster_counts.nrow,
		xlabel="Cluster",
		ylabel="Número de canciones",
		label="Counts",
		legend=:top,
		color=c,
		xticks=xt)
end

# ╔═╡ d92f7df8-cae8-4a2a-9015-0311326e24a5
function feature_subplots(features, df)
    plots = []

    for f in features
        p = boxplot(
            df.cluster,
            df[!, f],
            xlabel = f,
            markersize = 5,
            size = (800, 1000),
			group = df.cluster,
			legend = false,
			xticks = xt,
			palette = c
        )
		
        push!(plots, p)
    end

	rows = length(features) ÷ 2
    rows += length(features) % 2
	
    plot(plots..., layout = (rows, 2))
end

# ╔═╡ 9f05197a-61e7-4c6a-878c-59cfaa277b66
begin
	features = names(recommended_df[:, Not(:cluster, :uri)])
	feature_subplots(features, recommended_df)
end

# ╔═╡ 24d4ec4d-5beb-49b6-b4d4-133b8e93be7f
N_SONGS_PER_PLAYLIST = 25

# ╔═╡ 47968f84-696b-4018-b15c-d608b5c2a538
begin
	DISTANCE_IDX = 2
	
	function find_most_similar_rows(df, target_row)
	    distances = [
			(index, euclidean(target_row, df[index, :]))
			for index in 1:size(df, 1)
		]
	    return sort(distances, by = x -> x[DISTANCE_IDX])[1:N_SONGS_PER_PLAYLIST,]
	end

	function add_similar_songs(df, dict, cluster)
		dict[cluster] = []
		cluster_df = filter(row -> row.cluster == cluster, df)
		centroid = clusters.centers[:, cluster]
		similar_rows = 
			find_most_similar_rows(select(cluster_df, Not(:cluster, :uri)), centroid)
		
		for (index, distance) in similar_rows
			push!(dict[cluster], df[index, :].uri)
		end
	end
end

# ╔═╡ fccc849b-c8b9-4f15-80bc-c97e22ea2b81
begin
	songs = Dict{Int, Vector{String}}()
	songs_threads = [
		Threads.@spawn add_similar_songs(recommended_df, songs, cluster)
		for cluster in (1:N_CLUSTERS)
	]

	for thread in songs_threads
		wait(thread)
	end
end

# ╔═╡ 5006ea0a-c26c-4e9c-a422-cdb54e6415d9
function create_playlist(name, uris)
	url = "https://api.spotify.com/v1/me/playlists"

	 playlist_data = Dict(
        "name" => name,
        "description" => "Creada usando Julia!"
    )
	
	response = HTTP.request("POST", url, COMMON_REQ_HEADERS, json(playlist_data))
	if response.status == 201
		playlist_id = JSON.parse(String(response.body))["id"]
		add_tracks_url = "https://api.spotify.com/v1/playlists/$playlist_id/tracks"
		HTTP.request("POST", add_tracks_url, COMMON_REQ_HEADERS, json(Dict("uris" => uris)))
	else
		println("Error al crear playlist")
	end
end

# ╔═╡ 2dd20f72-cc29-49cb-8ea4-c87b35a06b0c
begin
	playlists_threads = [
    	Threads.@spawn create_playlist("TDL - Playlist $cluster", tracks)
		for (cluster, tracks) in songs
	]

	for thread in playlists_threads
		wait(thread)
	end
end

# ╔═╡ Cell order:
# ╠═67af2076-8097-4365-b976-9baad57c05e2
# ╠═5adaa470-86b2-4745-a3c1-88510829685f
# ╟─457cf7cd-fb6b-43f5-8eff-9c5b7ef7cf30
# ╠═a4ef2dc5-4ab7-45fd-8c11-48622071225b
# ╠═29cd8672-dd23-4138-a25a-ed138ba2def7
# ╠═f700e47b-e3e3-4eda-9d90-29aa3783025a
# ╠═62a4ff13-43bb-4b59-bcbb-2e74cd6ba354
# ╠═4b10d8e9-c9da-4686-a2fb-6fac57bcb745
# ╠═f7632afb-3dbf-4c13-b7ae-1bd56692423d
# ╠═984ac556-e740-44c0-9cbd-460fce6b89f8
# ╠═ffe2da34-9230-438c-88f4-801ae8c81b0e
# ╠═2901c05b-42f5-4f81-ba20-b336219afce0
# ╠═a199fb94-1803-4094-b44a-e503dd1844d1
# ╠═5a457784-6cb8-44d5-9858-95e2f6ad1e06
# ╠═ea46b8df-3169-4b8d-a46c-f6a7aca19638
# ╠═1ee97f80-8928-4bc5-9bc6-eeaa5f4261dd
# ╠═dc442071-2cf1-4e46-94ed-d4432d9fa35e
# ╠═8e42c99b-c290-4772-9012-6f3e51d83ac1
# ╠═fc9d5801-be91-4798-bd00-0799810c46a7
# ╠═88f1ad35-5f30-42a9-88a2-6cace430c25c
# ╠═ce8bc685-5f91-4dc6-bde0-9dfecbee6442
# ╠═52bbcc98-8697-4ed3-bcdb-feae1a51d9c6
# ╠═87105d9b-99b2-4285-9cbe-6887f638c615
# ╠═e8a021d4-320c-494b-b4bf-23a931e67e16
# ╠═8bf68b8f-1a4b-43f5-a5a9-d5e07adc02d4
# ╠═d028886c-45a5-4cd3-93e4-f3434f79bbd1
# ╠═19abc750-cece-4bd2-b8d3-cf5489156560
# ╠═f7513326-72be-4bf6-b259-891578726b7d
# ╠═43174160-8229-49bb-8c6c-af934cfd9380
# ╠═5ff846d3-6e92-4eba-9e10-27869fe831ee
# ╠═241a843e-6fb5-4433-b49a-3a8c26b47d68
# ╟─11b398d9-4453-4e4c-9c26-c4dafddad171
# ╠═adb3da2a-e2d2-41f5-8e54-e89c7db9dd86
# ╠═f728f427-c67c-4536-b51a-ebf020609da8
# ╠═3d156acc-d820-41d8-ab04-615b07aa53c3
# ╠═47e503b0-b291-4aaf-a174-11103a200354
# ╠═c7446543-7622-4140-9aae-ed37eceef159
# ╠═5a565a54-ab2c-41d9-931e-1ea835df3b65
# ╠═e82495d6-7070-4b79-9a9d-301f1fbebd4b
# ╠═803356ce-9ebc-44c2-b046-a99e1088d662
# ╠═66f01f4b-7c04-4e5f-adcb-c5514fa0ef05
# ╠═80212680-af5f-464d-9f28-8e3c526cfce1
# ╠═c5ec84dd-06ac-433f-8e55-72932891bcbe
# ╠═ec787a8f-9821-49ba-bae3-3f37c958bb71
# ╠═5e883871-e5b4-41dd-bd0c-3b1299ff62df
# ╠═d67f578e-4ead-42e8-97c5-9c61a0b0fc2f
# ╠═ac3fcb59-990a-4128-ba5a-760b89fb3742
# ╠═33138cfb-bae4-4dfd-a010-860b42d0dcbe
# ╠═c98cf96e-8555-4ec0-9f23-70dc13470acc
# ╠═608a4f93-278c-47a7-b45e-97b46c3fc295
# ╠═37f86c36-6b32-475f-b191-dd17ac334669
# ╠═7aa537cb-455e-4469-873d-2a9e4cddc109
# ╠═4395cc1e-b5e7-43e2-a439-0d8baa37dbbf
# ╠═f792b205-2a4f-4244-8530-297eeed068d0
# ╠═ac35e817-314d-4a98-9cee-32f3361e8920
# ╠═4aba3555-2d08-44e8-b3cc-7962f5b42b70
# ╠═d92f7df8-cae8-4a2a-9015-0311326e24a5
# ╠═9f05197a-61e7-4c6a-878c-59cfaa277b66
# ╠═24d4ec4d-5beb-49b6-b4d4-133b8e93be7f
# ╠═47968f84-696b-4018-b15c-d608b5c2a538
# ╠═fccc849b-c8b9-4f15-80bc-c97e22ea2b81
# ╠═5006ea0a-c26c-4e9c-a422-cdb54e6415d9
# ╠═2dd20f72-cc29-49cb-8ea4-c87b35a06b0c
