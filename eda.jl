### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ a1c5360a-de7d-4b8d-907f-025872b5c4d3
import Pkg; Pkg.add("Plots")

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

# ╔═╡ 4197ab47-8622-4ebf-99c1-a350ed6cf7ca
using CSV

# ╔═╡ 530a90c9-4972-44e5-812e-7dbd610bb6da
using DataFrames

# ╔═╡ 1a1251f3-86bd-43c1-b1c4-17ceae07f125
using Statistics

# ╔═╡ 0d59739e-aea8-470c-b72e-35aa5ff49669
using Plots

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

# ╔═╡ bb8004c0-eda4-4657-b737-9d10ca274a75


# ╔═╡ Cell order:
# ╠═fdc1a8f6-8161-11ee-1711-5f68fb1ab9af
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
# ╠═bb8004c0-eda4-4657-b737-9d10ca274a75
