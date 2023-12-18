# tdl-2023-2c-l-julia-insertid


### Activar el proyecto e instalar dependencias

Primero abrir el intérprete de comandos de Julia:

```bash
julia
```

Luego ejecutar:

```julia
using Pkg
Pkg.activate("spotify-tdl")
Pkg.instantiate()
```

Asegurarse de descargar el dataset y dejarlo en root del proyecto:

[Dataset 1 million tracks Spotify](https://www.kaggle.com/datasets/amitanshjoshi/spotify-1million-tracks)

### Correr la notebook Pluto

```julia
using Pluto
Pluto.run()
```

### Credenciales: API Spotify

Al tratarse de información delicada, en este trabajo guardamos nuestras credenciales para la API de Spotify dentro de un archivo .env, el cual se puede cargar con la librería DotEnv, la cual es bastante común en todos los lenguajes. En el repositorio dejamos un archivo .env_sample para mostrar la forma que debería tener.

```
TDL_SPOTIFY_CLIENT_ID="mi_id"
TDL_SPOTIFY_CLIENT_SECRET="mi_secret"
TDL_CALLBACK_URI="http://localhost:8888/callback"
```

Tanto la creación de la aplicación de Spotify como la obtención de credenciales de la misma se puede hacer desde:

[Dashboard de la API de Spotify](https://developer.spotify.com/)

## Links de interes:

[Libro Julia Data Science](https://juliadatascience.io/)

[Playlist clustering & machine learning](https://youtube.com/playlist?list=PLhQ2JMBcfAsi76O13sJzk4LXA_mu5sd9E&si=hbJolu0wrEGaD6Dv)

### Benchmarks
[Gráfico de Julia vs otros lenguajes: Julia Data Science Cap. 2.3](https://juliadatascience.io/images/benchmarks.png)

[Artículo The Need for Speed de Mason White](https://www.researchgate.net/publication/357825090_The_Need_for_Speed_Julia_Vs_Python)

[Benchmarks de Vercel App](https://programming-language-benchmarks.vercel.app/julia-vs-python)
