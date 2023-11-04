### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 5adaa470-86b2-4745-a3c1-88510829685f
using Pluto

# ╔═╡ d91126af-6ad3-4b11-b6de-65eaf9b6d9cd
using Markdown

# ╔═╡ 7076fff5-057d-4b5a-b0bd-d421efcc173a
using DotEnv

# ╔═╡ 17645da3-8bee-4aef-bd2d-8867e3107707
using HTTP

# ╔═╡ b3e00154-dc43-4b5a-9eaf-3cb15c67ac45
using JSON

# ╔═╡ 2f7057c1-174c-4b10-9d88-c25679d8e9b6
using Base64

# ╔═╡ 61952dda-7ec1-4191-912d-3c1c94868add
using DataFrames

# ╔═╡ 69c5f944-7778-11ee-1473-eff633c169cb
println("Hola TDL!")

# ╔═╡ 11b398d9-4453-4e4c-9c26-c4dafddad171
Markdown.parse("""
# Definición de API KEY
"""
)

# ╔═╡ 3c6c8cfd-0029-4da7-abf7-01d686b3bc00
# ╠═╡ show_logs = false
run(`python3 authenticate.py`)

# ╔═╡ 3a94f749-6894-4c68-bbda-2a8e12aeecbd
DotEnv.load()

# ╔═╡ af731e20-65e7-45b9-b096-a6bdab35b2fa
client_id = ENV["TDL_SPOTIFY_CLIENT_ID"]

# ╔═╡ 8f0a750d-becf-4649-ab86-6f2eb146a253
client_secret = ENV["TDL_SPOTIFY_CLIENT_SECRET"]

# ╔═╡ 5c2f5c51-42e0-44bf-8738-8ba0ee87d271
# ╠═╡ disabled = true
#=╠═╡
auth_code = nothing
  ╠═╡ =#

# ╔═╡ 2556d7a6-4034-4db2-963e-b634015085e9
callback_uri = "http://localhost:8888/callback"

# ╔═╡ adb3da2a-e2d2-41f5-8e54-e89c7db9dd86
begin
	function get_token_req_body_headers()
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

# ╔═╡ e30200a8-bf3c-461f-9f54-38b8e11176f6
begin
	token_request_headers, token_request_body = get_token_req_body_headers()
	token = get_api_token(token_request_headers, token_request_body)
end

# ╔═╡ 92fb20d6-b5f2-4085-931e-f319ea36c899
DotEnv.load()

# ╔═╡ 47e503b0-b291-4aaf-a174-11103a200354
function get_track_info(track_id)
	track_url = "https://api.spotify.com/v1/tracks/$track_id"
	tracks_headers = [
	    "Authorization" => "Bearer $token",
	    "Content-Type" => "application/json",
	]
	
	track_response = HTTP.get(track_url, tracks_headers)
	if track_response.status == 200
	    track_result = JSON.parse(String(track_response.body))
	    return track_result
	else
	    println("Error al obtener los datos de la API de Spotify")
		return nothing
	end
end

# ╔═╡ 90b73111-28dd-4ece-a788-d6844c578524
AUX_TRACK_ID = "0eGsygTp906u18L0Oimnem"

# ╔═╡ bade93ab-3ddc-4098-930f-4bf36e5e6f44
AUX_TRACK_ID_LIST = ["7ouMYWpwJ422jRcDASZB7P","4VqPOruhp5EdPBeR92t6lQ","2takcwOaAZWiXQijPHIx7B"]

# ╔═╡ 02660102-6a75-4076-860a-261a13348ca3
track_info = get_track_info(AUX_TRACK_ID)

# ╔═╡ c7446543-7622-4140-9aae-ed37eceef159
function get_track_audio_features(track_id)
    audio_features_url = "https://api.spotify.com/v1/audio-features/$track_id"
    audio_features_headers = Dict(
        "Authorization" => "Bearer $token",
        "Content-Type" => "application/json"
    )
    audio_features_response = HTTP.get(audio_features_url, audio_features_headers)
	
    if audio_features_response.status == 200
        audio_features_result = JSON.parse(String(audio_features_response.body))
        return audio_features_result
    else
        println("Error al obtener los datos de las características de audio de la API de Spotify")
        return nothing
    end
end

# ╔═╡ f540ec75-abc5-4537-a90e-e6939229b364
get_track_audio_features(AUX_TRACK_ID)

# ╔═╡ 5a565a54-ab2c-41d9-931e-1ea835df3b65
function get_favorite_tracks()
	favorites_url = "https://api.spotify.com/v1/me/top/tracks"
	favorites_headers = Dict("Authorization" => "Bearer $token")
	favorites_response = HTTP.get(favorites_url, favorites_headers)

    if favorites_response.status == 200
        favorites = JSON.parse(String(favorites_response.body))
        return favorites
    else
        println("Error al obtener los datos de tus canciones favoritas de la API de Spotify")
        return nothing
    end
end

# ╔═╡ b6ce57b4-06ec-4c66-91fb-d6f22ff6ff68
favorite_tracks = get_favorite_tracks()

# ╔═╡ d67f578e-4ead-42e8-97c5-9c61a0b0fc2f
function get_audio_features_multiple_tracks(ids)
    # Codifica los IDs de las pistas para que sean compatibles con la URL
    encoded_ids = join(map(x -> replace(x, "/" => "%2F", "+" => "%2B", " " => "%20"), ids), ",")

    audio_features_url = "https://api.spotify.com/v1/audio-features?ids=$encoded_ids"
    audio_features_headers = Dict(
        "Authorization" => "Bearer $token",
        "Content-Type" => "application/json"
    )

    audio_features_response = HTTP.get(audio_features_url, audio_features_headers)
    if audio_features_response.status == 200
        audio_features_result = JSON.parse(String(audio_features_response.body))
        return audio_features_result
    else
        println("Error al obtener los datos de las características de audio de la API de Spotify")
        return nothing
    end
end

# ╔═╡ ac3fcb59-990a-4128-ba5a-760b89fb3742
tracks_features_dict = get_audio_features_multiple_tracks(AUX_TRACK_ID_LIST)

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Base64 = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DotEnv = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"

[compat]
DataFrames = "~1.6.1"
DotEnv = "~0.3.1"
HTTP = "~1.10.0"
JSON = "~0.21.4"
Pluto = "~0.19.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "7c876ed26014014262a7654bff01a645a2d79ba5"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "4358750bb58a3caefd5f37a4a0c5bfdbbf075252"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.6"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DotEnv]]
git-tree-sha1 = "d48ae0052378d697f8caf0855c4df2c54a97e580"
uuid = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
version = "0.3.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.ExproniconLite]]
git-tree-sha1 = "637309d52dd9034af79c9df9b5f07a824e30ca2f"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.4"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "c8d37d615586bea181063613dccc555499feb298"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.5.3"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "410fe4739a4b092f2ffe36fcb0dcc3ab12648ce1"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Malt]]
deps = ["Distributed", "Logging", "RelocatableFolders", "Serialization", "Sockets"]
git-tree-sha1 = "5333200b6a2c49c2de68310cede765ebafa255ea"
uuid = "36869731-bdee-424d-aa32-cab38c994e3b"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "fc8c15ca848b902015bd4a745d350f02cf791c2a"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.2.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc6e1927ac521b659af340e0ca45828a3ffc748f"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.12+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.Pluto]]
deps = ["Base64", "Configurations", "Dates", "Downloads", "FileWatching", "FuzzyCompletions", "HTTP", "HypertextLiteral", "InteractiveUtils", "Logging", "LoggingExtras", "MIMEs", "Malt", "Markdown", "MsgPack", "Pkg", "PrecompileSignatures", "PrecompileTools", "REPL", "RegistryInstances", "RelocatableFolders", "Scratch", "Sockets", "TOML", "Tables", "URIs", "UUIDs"]
git-tree-sha1 = "0b61bd2572c7c797a0e0c78c40b8cee740996ebb"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.19.32"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileSignatures]]
git-tree-sha1 = "18ef344185f25ee9d51d80e179f8dad33dc48eb1"
uuid = "91cefc8d-f054-46dc-8f8c-26e11d7c5411"
version = "3.0.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "6842ce83a836fbbc0cfeca0b5a4de1a4dcbdb8d1"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.8"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "1fbeaaca45801b4ba17c251dd8603ef24801dd84"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.2"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═5adaa470-86b2-4745-a3c1-88510829685f
# ╠═69c5f944-7778-11ee-1473-eff633c169cb
# ╠═d91126af-6ad3-4b11-b6de-65eaf9b6d9cd
# ╟─11b398d9-4453-4e4c-9c26-c4dafddad171
# ╠═7076fff5-057d-4b5a-b0bd-d421efcc173a
# ╠═3c6c8cfd-0029-4da7-abf7-01d686b3bc00
# ╠═3a94f749-6894-4c68-bbda-2a8e12aeecbd
# ╠═af731e20-65e7-45b9-b096-a6bdab35b2fa
# ╠═8f0a750d-becf-4649-ab86-6f2eb146a253
# ╠═5c2f5c51-42e0-44bf-8738-8ba0ee87d271
# ╠═17645da3-8bee-4aef-bd2d-8867e3107707
# ╠═b3e00154-dc43-4b5a-9eaf-3cb15c67ac45
# ╠═2556d7a6-4034-4db2-963e-b634015085e9
# ╠═2f7057c1-174c-4b10-9d88-c25679d8e9b6
# ╠═adb3da2a-e2d2-41f5-8e54-e89c7db9dd86
# ╠═e30200a8-bf3c-461f-9f54-38b8e11176f6
# ╠═92fb20d6-b5f2-4085-931e-f319ea36c899
# ╠═47e503b0-b291-4aaf-a174-11103a200354
# ╠═90b73111-28dd-4ece-a788-d6844c578524
# ╠═bade93ab-3ddc-4098-930f-4bf36e5e6f44
# ╠═02660102-6a75-4076-860a-261a13348ca3
# ╠═c7446543-7622-4140-9aae-ed37eceef159
# ╠═f540ec75-abc5-4537-a90e-e6939229b364
# ╠═5a565a54-ab2c-41d9-931e-1ea835df3b65
# ╠═b6ce57b4-06ec-4c66-91fb-d6f22ff6ff68
# ╠═d67f578e-4ead-42e8-97c5-9c61a0b0fc2f
# ╠═ac3fcb59-990a-4128-ba5a-760b89fb3742
# ╠═61952dda-7ec1-4191-912d-3c1c94868add
# ╠═33138cfb-bae4-4dfd-a010-860b42d0dcbe
# ╠═c98cf96e-8555-4ec0-9f23-70dc13470acc
# ╠═608a4f93-278c-47a7-b45e-97b46c3fc295
# ╠═37f86c36-6b32-475f-b191-dd17ac334669
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
