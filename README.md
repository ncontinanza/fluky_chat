# FlukyChat

*FlukyChat* es un chat implementado en Elixir donde usuarios pueden interactuar por un tiempo determinado con otros usuarios enviándose mensajes hasta que suceda un *shuffle* que provocará que cambie el usuario con quien se está chateando por cualquier otro usuario aleatorio que esté conectado al chat.

### Requerimientos

- Elixir (indicaciones para instalarlo en múltiples sistemas operativos en https://elixir-lang.org/install.html).

### Ejecución

Una vez teniendo el proyecto clonado, accedemos al directorio principal y podemos ejecutar los siguientes comandos para interactuar con la aplicación.

1. Debido se utilizó *Mix* (una herramienta que, en simples palabras, genera estructura y archivos necesarios para un proyecto) debemos iniciar y cargar los archivos del proyecto:

```$ iex -S mix```

2. Ya dentro del *Interactive* de *Elixir*, debemos levantar el servidor de *FlukyChat*:

```iex(1)> FlukyChat.start```

3. A continuación, ya estamos listos para interactuar con el servidor. Esto lo haremos a partir de simplemente abrir nuevas ventanas y utilizar *netcat* para conectarnos eligiendo como host al `localhost` y como puerto al `4040`:

```$ netcat localhost 4040```

#### Comandos de usuario

Una vez conectados, los usuarios pueden interactuar con la aplicación y otros clientes a partir de los siguientes comandos:

- `:h` -> Muestra un instructivo (similar a este) sobre el uso de cada comando.
- `:t` -> Muestra el tiempo restante antes de que suceda el *shuffle* en el chat.
- `:m [mensage]` -> Envía el mensaje `[mensaje]` al usuario que se está hablando hablando actualmente. Ees opcional, es decir, por default escribir un mensaje y apretar `enter` envía un mensaje aunque no se explicite el `:m`.
- `:n [nuevo_nickname]` -> Actualiza el nickname a `nuevo_nickname`.
- `Ctrl+C` -> Desconecta al usuario del chat.

### Referencias

  * Sitio oficial de Elixir: https://elixir-lang.org/
