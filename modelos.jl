### A Pluto.jl notebook ###
# v0.19.39

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 6a54a62b-732c-4d5a-827e-beca0b6425c8
using Graphs, Random, Plots, Statistics, StatsPlots, GraphMakie, ColorSchemes, Makie, CairoMakie, FileIO, ImageMagick, Images, PlutoUI, Distributions

# ╔═╡ 01a11336-d9f2-4ea3-8f49-8e0c5377a917
html"""
<h1 style="text-align: center;">Proyecto</h1>
"""

# ╔═╡ f47e47b8-7f13-4cf3-a017-c2d33550e3fc
html"""
<h2 style="text-align: center;">Modelo 1</h2>
"""

# ╔═╡ ee8bfb9a-ad5f-4957-9916-157782181b40
html"""
<h4 style="text-align: center;">Competencia de dos ideas opuestas</h4>
"""

# ╔═╡ f04ed5bd-65a3-49aa-9a00-a72a96379fbb
html"""
<h5 style="text-align: center;">(Parámetros globales)</h5>
"""

# ╔═╡ ca9c8488-52ee-426d-a15e-af6eee622c6b
md"""
##### Consideraciones del modelo:
"""

# ╔═╡ 5d2f9b3a-c2d3-430c-9efd-fe418123fd69
md"""
**1. Estructura de la red social:** Representada como un grafo donde los nodos son agentes y las aristas son conexiones sociales.

**2. Estados de los agentes:** Cada agente puede estar en uno de tres estados: creer en una idea $\phi$, creer en la idea contraria $\neg\phi$, o ser indiferente $\bot$.

**3. Transiciones entre estados:** Los agentes pueden cambiar de estado basado en los mensajes que reciben de sus vecinos.
   
   - Hay dos probabilidades/parámetros clave: $\lambda$ (probabilidad de adoptar una idea) y $\mu$ (probabilidad de abandonar una idea).

**4. Proceso de difusión:**
   - En cada paso, un agente es seleccionado al azar para transmitir su creencia.
   - Los agentes conectados a este agente pueden cambiar su estado basado en el mensaje recibido.

**6. Simulación Monte Carlo:** Realizamos múltiples ejecuciones del modelo para obtener resultados estadísticamente significativos.

"""

# ╔═╡ d03e277c-eef0-40cd-8d59-dbbccb328d5b
md"""
##### Implementación:
"""

# ╔═╡ 2a8acc84-d044-46ea-9c94-c0abad85600b
md"""
Definimos los posibles estados de cada individuo/agente, usamos un tipo enumerado `State` para representar los posibles estados de los agentes.
"""

# ╔═╡ 3ad17618-7348-4345-883b-4055ba3d2f9c
@enum State phi notphi ind

# ╔═╡ f3d9c1fb-b924-43ce-a498-daaa8d3dd48b
md"""
Definimos la estructura `Agent`, que cuenta con un número de identificación y el estado del agente. La estructura `Agent` es mutable, lo que permite cambiar su estado.
"""

# ╔═╡ 10ab3b8e-0cfc-4796-97de-94ad03e38020
mutable struct Agent
    id::Int
    state::State
end

# ╔═╡ e87e03fe-1728-4784-ba43-953fc424d257
md"""
Función que simula el recibimiento de un mensaje y que, según los parámetros, el agente decidirá si adoptar o no la creencia de quien envió el mensaje (en caso de que el agente sea indiferente). En caso de que cuente con un estado distinto al mensaje, este decidirá si seguir con su creencia actual o pasar a un estado de indiferencia.
"""

# ╔═╡ 4609932c-13e1-4b0e-92a7-83209af85f62
function receive_message!(agent::Agent, message::State, λ::Float64, μ::Float64)
    if agent.state == ind
        if rand() < λ
            agent.state = message
        end
    elseif agent.state != message
        if rand() < μ
            agent.state = ind
        end
    end
end

# ╔═╡ cac9f915-b3a6-483b-8adb-27c3d4584b21
md"""
Definimos la estructura `SocialNetwork`, compuesta por el grafo de la estructura y un vector con los agentes de la misma:
"""

# ╔═╡ a6c50d2c-6467-4aa4-bfa3-64b5b61ee632
struct SocialNetwork
    graph::SimpleGraph
    agents::Vector{Agent}
end

# ╔═╡ d7962869-7d12-4ca5-9a0b-1f21b05a16ca
md"""
Función para inicializar una red social, con todos los agentes en estado indiferente:
"""

# ╔═╡ bba48b66-23ee-4474-963e-cc56df2c1c17
function socialNetwork(num_agents::Int)
    graph = barabasi_albert(num_agents, 3) # cambiar esto según  el tipo de grafo
    agents = [Agent(i, ind) for i in 1:num_agents]
    SocialNetwork(graph, agents)
end

# ╔═╡ a3dfdda7-25fe-42c2-bb3f-f83e4c89d9a8
md"""
Para este caso en particular, generaremos la red social utilizando el algoritmo [Barabási-Albert](https://es.wikipedia.org/wiki/Modelo_Barabási–Albert). Para ver más tipos de grafos visitar [esto](https://juliagraphs.org/Graphs.jl/dev/core_functions/simplegraphs_generators/).
"""

# ╔═╡ 44f648d0-3aac-4428-b408-b545caec064d
md"""
Implementamos una función para setear los estados semilla:
"""

# ╔═╡ d156a007-ea53-477a-991a-afe4e8abb049
function set_seed_nodes!(network::SocialNetwork, phi_seed::Int, notphi_seed::Int)
    network.agents[phi_seed].state = phi
    network.agents[notphi_seed].state = notphi
end

# ╔═╡ 446e25cf-ea39-44cf-8923-8024be3afce0
md"""
En este modelo consideramos dos nodos semillas: uno con el estado $\phi$ y uno con el estado $\neg\phi$.
"""

# ╔═╡ f267b68e-739d-4a04-b3d7-516afeab8b15
md"""
Implementamos una función que simula un paso de la cadena, en este se elige un nodo aleatorio y, en caso de que dicho nodo no sea indiferente, se comparte su creencia con sus vecinos:
"""

# ╔═╡ 0c35af1a-5a85-4bf6-b53a-03743043c6fc
function simulate_step!(network::SocialNetwork, λ::Float64, μ::Float64)
    sender = rand(network.agents)
    if sender.state != ind # verificamos que quien envía no sea indiferente
        for neighbor in neighbors(network.graph, sender.id)
            receive_message!(network.agents[neighbor], sender.state, λ, μ)
        end
    end
end

# ╔═╡ 945fc349-ec9d-4647-982a-195ef6f43a19
md"""
Algo que intentaremos más adelante es mejorar la manera en la que elegimos el nodo aleatorio que manda el mensaje, pues tiene más sentido que se elijan estados no indiferentes.
"""

# ╔═╡ 89dc04cc-4d4e-4bdf-aa2e-20e93da92d30
md"""
La siguiente función nos permite contar el número de agentes adeptos a cada uno de los estados:
"""

# ╔═╡ a4a14bb1-a824-4d03-a259-fa44dbe6f2d3
function count_beliefs(network::SocialNetwork)
    beliefs = Dict(s => count(a -> a.state == s, network.agents) for s in instances(State))
    return beliefs
end

# ╔═╡ 440f5307-8ba1-4a29-a58c-55ef16f82959
md"""
Finalmente, implementamos una función que nos permite correr la simulación completa:
"""

# ╔═╡ 2cfda743-eebb-41be-a7c3-4d77c0fe57fb
function run_simulation(num_agents::Int, num_steps::Int, λ::Float64, μ::Float64, num_runs::Int)
    results = []
    for _ in 1:num_runs
        network = socialNetwork(num_agents)
        set_seed_nodes!(network, 1, 2)  # Se toma 1 y 2 como nodos semillas
        
        run_results = []
        for step in 1:num_steps
            simulate_step!(network, λ, μ)
            push!(run_results, count_beliefs(network))
        end
        
        push!(results, run_results)
    end
    return results
end

# ╔═╡ 50d68bba-51ea-4ee8-998e-899bcf10835c
md"""
Veamos un ejemplo de uso:
"""

# ╔═╡ be2a095c-f611-4401-a209-808f95d02be7
sim_results = run_simulation(100, 1000, 0.5, 0.5, 1000)

# ╔═╡ df9e046f-3df8-4c6c-8624-1a671d249943
md"""
Implementamos una función para visualizar los resultados. Esta función crea un gráfico de líneas que muestra cómo evoluciona el número esperado de agentes en cada estado ($\phi$, $\neg\phi$, $\bot$) a lo largo de los pasos de la simulación.
"""

# ╔═╡ 3a5b442a-2f35-4b3b-9bef-dc7386846695
function plot_belief_evolution(results)
    num_steps = length(results[1])
    num_runs = length(results)
    
    phi_means = [mean([run[step][phi] for run in results]) for step in 1:num_steps]
    notphi_means = [mean([run[step][notphi] for run in results]) for step in 1:num_steps]
    ind_means = [mean([run[step][ind] for run in results]) for step in 1:num_steps]
    
    Plots.plot(1:num_steps, [phi_means notphi_means ind_means], 
         label=["φ" "¬φ" "⊥"],
         title="Evolución de creencias",
         xlabel="Pasos de simulación",
         ylabel="Número promedio de agentes",
         lw=2)
end

# ╔═╡ 3bbc2f23-460f-4e9a-bc76-0d364b8605de
md"""
Y una función para visualizar el estado final de la cadena. Esta función crea un diagrama que muestra la distribución del número de agentes en cada estado al final de las simulaciones.
"""

# ╔═╡ 4c4d6cb7-caeb-4768-8e89-be9b468a5e9c
function plot_final_distribution(results)
    final_states = [last(run) for run in results]
    
    phi_counts = [state[phi] for state in final_states]
    notphi_counts = [state[notphi] for state in final_states]
    ind_counts = [state[ind] for state in final_states]
    
    means = [mean(phi_counts), mean(notphi_counts), mean(ind_counts)]
    stds = [std(phi_counts), std(notphi_counts), std(ind_counts)]
	
    labels = ["φ", "¬φ", "⊥"]
	
    p = Plots.bar(labels, means, 
        yerr=stds,
        title="Distribución final de creencias",
        ylabel="Número promedio de agentes",
        legend=false,
        color=:orange,
        alpha=0.6)
end

# ╔═╡ 5fdb4de2-d240-4cd4-9263-7c3334bb30d4
begin
	p1 = plot_belief_evolution(sim_results)
	p2 = plot_final_distribution(sim_results)
	Plots.plot(p1, p2, layout=(2,1), size=(950,1000))
end

# ╔═╡ 5ad8a283-9233-4a1c-a883-89164c5f1ae5
md"""
La anterior gráfica muestra la evolución del número esperado de agentes con la creencia $\phi$, $\neg\phi$ e $\bot$. Del total de pasos que se realizaron, no en todos se envió un mensaje desde un nodo a otro, pues si en un paso se elegía un agente indiferente, este no hacía nada. Veamos en promedio cuantos mensajes se enviaban después del total de simulaciones, esto para darnos una idea del número de mensajes que se requieren para que la cadena converja (empiricamente a un estado en el que la mitad de los agentes cree $\phi$ y la otra mitad cree $\neg\phi$). Para esto implementamos la función `count_mean_messages_sent`.
"""

# ╔═╡ f122a536-077e-4dc6-8147-9932728bdb44
function count_mean_messages_sent(simulation_results)
    num_runs = length(simulation_results)
    messages_per_run = zeros(Int, num_runs)
    
    for (run, result) in enumerate(simulation_results)
        messages = 0
        prev_state = result[1]
        for state in result[2:end]
            if state != prev_state
                messages += 1
            end
            prev_state = state
        end
        messages_per_run[run] = messages
    end
    
    mean_messages = mean(messages_per_run)
    return mean_messages, messages_per_run
end

# ╔═╡ 84512246-1d25-4a9c-b6aa-3e7bf84aa003
begin
mean_messages, messages_per_run = count_mean_messages_sent(sim_results)
    println("Media de mensajes enviados: $(round(mean_messages, digits=2))")
    println("Rango de mensajes enviados: $(minimum(messages_per_run)) - $(maximum(messages_per_run))")
end

# ╔═╡ f49fab3a-3840-41ff-b2ca-81ae2d7ef7b4
md"""
Finalmente, implementaremos una función para visualizar una de las simulaciones:
"""

# ╔═╡ ef946d84-2f18-467e-a53e-420c7a0be837
function visualize_network_evolution(simulation_results, network)
    layout = GraphMakie.spring(network.graph)
    
    fig = Figure(size = (800, 600))
    ax = GraphMakie.Axis(fig[1, 1])
    
    function update_colors(i)
        return map(simulation_results[i]) do state
            if state == phi
                :blue
            elseif state == notphi
                :red
            else  # state == ind
                :green
            end
        end
    end
    
    node_colors = Observable(update_colors(1))
    p = graphplot!(ax, network.graph,
        layout = layout,
        node_color = node_colors,
        node_size = 15,
        edge_width = 1,
        edge_color = :gray80
    )
    
    legend_elements = [
        MarkerElement(color = :blue, marker = :circle, markersize = 15),
        MarkerElement(color = :red, marker = :circle, markersize = 15),
        MarkerElement(color = :green, marker = :circle, markersize = 15)
    ]
    legend_labels = ["φ", "¬φ", "⊥"]
    Legend(fig[1, 2], legend_elements, legend_labels, "Creencias")
    
    ax.title = "Evolución de la Red Social y Distribución de Creencias"
    
    slider = PlutoUI.Slider(1:length(simulation_results), default=1, show_value=true)
    
    function update_viz(i)
        node_colors[] = update_colors(i)
    end
    
    return fig, slider, update_viz
end

# ╔═╡ dd99f468-0208-439f-94a8-ea5dad16519f
# para contar los mensajes de una única simulación:
function count_messages(simulation_results)
    messages = 0
    prev_state = simulation_results[1]
    for state in simulation_results[2:end]
        if state != prev_state
            messages += 1
        end
        prev_state = state
    end
    return messages
end

# ╔═╡ 6f0b5f5c-e92d-4c8f-9299-9dc19f80f2b5
md"""
Corremos una única simulación y la visualizamos:
"""

# ╔═╡ 60e6038e-38b4-48bf-9ccb-60039a7adab9
function run_and_visualize_simulation(num_agents::Int, num_steps::Int, λ::Float64, μ::Float64)
    network = socialNetwork(num_agents)
    set_seed_nodes!(network, 1, 2)
    
    simulation_results = []
    for _ in 1:num_steps
        push!(simulation_results, [agent.state for agent in network.agents])
        simulate_step!(network, λ, μ)
    end

	messages_sent = count_messages(simulation_results)
    println("Número de mensajes enviados: $messages_sent")
	
    fig, slider, update_viz = visualize_network_evolution(simulation_results, network)
    
    return fig, slider, update_viz
end

# ╔═╡ 144d0782-615f-4b1a-b5fe-77ad5cdce738
md"""
Veamos una simulación: (distinta de las obtenidas en el resultado anterior)
"""

# ╔═╡ 5e2ac555-559c-4228-bb15-a8a9e470bb6f
fig, slider, update_viz = run_and_visualize_simulation(100, 1000, 0.5, 0.5);

# ╔═╡ cea801c9-deed-481f-8d4a-70f4bc4bed64
@bind step slider

# ╔═╡ bd470321-2fbf-4a2b-a340-81daeea4b9e7
begin
	update_viz(step)
	fig
end

# ╔═╡ 948a7137-a636-4379-a130-423872206dd3
html"""
<h2 style="text-align: center;">Modelo 2</h2>
"""

# ╔═╡ 91c132aa-cb64-4c61-b8a8-dea8d9f99225
html"""
<h4 style="text-align: center;">Competencia de dos ideas opuestas</h4>
"""

# ╔═╡ 69f17f3e-ecaa-457d-9b67-8af5826fa3ca
html"""
<h5 style="text-align: center;">(Parámetros locales)</h5>
"""

# ╔═╡ 3893a15a-b7cd-42f6-946f-3aefc63bd231
md"""
##### Consideraciones del modelo:
"""

# ╔═╡ 473e7834-96a7-40a3-a3a8-8838be14c3fb
md"""
Vamos a modificar el **modelo 1** para que cada agente tenga sus propios parámetros $\lambda$ y $\mu$. Esto podría permitir una mayor diversidad en el comportamiento de los agentes y potencialmente resultados más interesantes en la simulación.
"""

# ╔═╡ 3428a963-ea41-473e-9477-8baf1b9a9632
md"""
##### Implementación:
"""

# ╔═╡ a140845c-7e4d-4465-8691-92684801d7ee
md"""
Los estados posibles de cada agente se conservan: $\phi$, $\neg\phi$ y $\bot$.
"""

# ╔═╡ a32abcd7-dd97-42c4-98d4-82c1c37001ae
md"""
Modificamos la estructura `Agent` añadiendo los parámetros individuales de cada agente:
"""

# ╔═╡ dc6056fc-0d2f-476d-abf6-bdf67e4ee81f
mutable struct Agent2
    id::Int
    state::State
    λ::Float64  # Probabilidad individual de adoptar una idea
    μ::Float64  # Probabilidad individual de abandonar una idea
end

# ╔═╡ 70d66b1f-fc1c-4146-80c8-f95d8f5e296c
md"""
La estructura de la red social se conserva, incluyendo su grafo y un  vector con los agentes de la red.
"""

# ╔═╡ 45792cdd-5493-4e7d-868a-7ec35798674b
struct SocialNetwork2
    graph::SimpleGraph
    agents::Vector{Agent2}
end

# ╔═╡ 90b41932-68a2-4eaa-85a3-e78b339032fb
md"""
La función que simula el recibimiento de un mensaje ahora utiliza los parámetros $\lambda$ y $\mu$ específicos de cada agente.
"""

# ╔═╡ fe740999-0cec-4dc6-9944-6d656f1abd6b
function receive_message2!(agent::Agent2, message::State)
    if agent.state == ind
        if rand() < agent.λ
            agent.state = message
        end
    elseif agent.state != message
        if rand() < agent.μ
            agent.state = ind
        end
    end
end

# ╔═╡ d16d9230-752d-4f01-a05e-e61b1d93ec89
md"""
Actualizamos la función `socialNetwork`: Ahora toma rangos para $\lambda$ y $\mu$, y asigna valores aleatorios dentro de esos rangos a cada agente.
"""

# ╔═╡ 82972001-18b4-456f-b1f7-82092e2575f3
function socialNetwork2(num_agents::Int, λ_range::Tuple{Float64,Float64}, μ_range::Tuple{Float64,Float64})
    graph = barabasi_albert(num_agents, 3)
    agents = [Agent2(i, ind, rand(Uniform(λ_range...)), rand(Uniform(μ_range...))) for i in 1:num_agents]
    SocialNetwork2(graph, agents)
end

# ╔═╡ c4749612-72e7-48c9-b4ea-d80dee7bfc96
md"""
Función para establecer los nodos semilla:
"""

# ╔═╡ 15138ee3-a0de-4d9b-8f91-24a9d6ba64cd
function set_seed_nodes2!(network::SocialNetwork2, phi_seed::Int, notphi_seed::Int)
    network.agents[phi_seed].state = phi
    network.agents[notphi_seed].state = notphi
end

# ╔═╡ 0d0f64f1-b67c-41b1-86a6-5216da90a31e
md"""
Para simular un paso de la cadena:
"""

# ╔═╡ e581e1c1-b34b-4e05-aa61-bb6bcafeb254
function simulate_step2!(network::SocialNetwork2)
    sender = rand(network.agents)
    if sender.state != ind
        for neighbor in neighbors(network.graph, sender.id)
            receive_message2!(network.agents[neighbor], sender.state)
        end
    end
end

# ╔═╡ 93a93b9d-0770-41a1-b13f-5ea0b84aa37a
md"""
Para contar el número de agentes adeptos a cada uno de los estados:
"""

# ╔═╡ 6816f635-89c8-4802-9807-2971be8b6b0f
function count_beliefs2(network::SocialNetwork2)
    beliefs = Dict(s => count(a -> a.state == s, network.agents) for s in instances(State))
    return beliefs
end

# ╔═╡ 4aafb062-3d21-4605-b29d-c21760e39cb1
md"""
Actualizamos las funciones de simulación: `run_simulation` y `run_and_visualize_simulation` ahora toman rangos para $\lambda$ y $\mu$ en lugar de valores fijos.
"""

# ╔═╡ 7aea21e7-2e6e-464b-b2e0-7f3e558ed6e6
function run_simulation2(num_agents::Int, num_steps::Int, λ_range::Tuple{Float64,Float64}, μ_range::Tuple{Float64,Float64}, num_runs::Int)
    results = []
    for _ in 1:num_runs
        network = socialNetwork2(num_agents, λ_range, μ_range)
        set_seed_nodes2!(network, 1, 2)
        run_results = []
        for step in 1:num_steps
            simulate_step2!(network)
            push!(run_results, count_beliefs2(network))
        end
        push!(results, run_results)
    end
    return results
end

# ╔═╡ 2c557d4c-de35-4cd6-9e16-ce7f44cb0323
function run_and_visualize_simulation2(num_agents::Int, num_steps::Int, λ_range::Tuple{Float64,Float64}, μ_range::Tuple{Float64,Float64})
    network = socialNetwork2(num_agents, λ_range, μ_range)
    set_seed_nodes2!(network, 1, 2)
    simulation_results = []
    for _ in 1:num_steps
        push!(simulation_results, [agent.state for agent in network.agents])
        simulate_step2!(network)
    end
    
    messages_sent = count_messages(simulation_results)
    println("Número de mensajes enviados: $messages_sent")
    
    fig, slider, update_viz = visualize_network_evolution(simulation_results, network)
    return fig, slider, update_viz
end

# ╔═╡ c8d2f57b-e640-4888-9322-ecbd2eff551b
sim_results2 = run_simulation2(100, 1000, (0.3, 0.7), (0.3, 0.7), 100)

# ╔═╡ 7ca1ee7e-0d51-4d3b-b651-e779fd81c158
begin
    p1_ = plot_belief_evolution(sim_results2)
    p2_ = plot_final_distribution(sim_results2)
    Plots.plot(p1_, p2_, layout=(2,1), size=(950,1000))
end

# ╔═╡ c69214f7-0f5d-4162-bc22-b52697f0e327
begin
mean_messages2, messages_per_run2 = count_mean_messages_sent(sim_results2)
    println("Media de mensajes enviados: $(round(mean_messages2, digits=2))")
    println("Rango de mensajes enviados: $(minimum(messages_per_run2)) - $(maximum(messages_per_run2))")
end

# ╔═╡ 3de17f3d-e297-4c31-b628-2b04102124f6
md"""
Veamos una simulación: (distinta de las obtenidas en el resultado anterior)
"""

# ╔═╡ 2771ccfc-a23b-4aa1-a37f-529792a33819
fig2, slider2, update_viz2 = run_and_visualize_simulation2(10, 100, (0.3, 0.7), (0.3, 0.7));

# ╔═╡ 9ed9b4b1-8b4a-4e05-9409-bf2564a99983
@bind step2 slider2

# ╔═╡ bab20706-0ba9-4a80-b72a-3a4baf4d6f7e
begin
	update_viz2(step2)
	fig2
end

# ╔═╡ 4785d3de-9b35-4883-b192-efa69389fb0c
html"""
<h2 style="text-align: center;">Modelo 3</h2>
"""

# ╔═╡ 0da863d5-1e24-4862-b583-c4233c3fdbe6
html"""
<h4 style="text-align: center;">Difusión de un mensaje</h4>
"""

# ╔═╡ fa4f3c36-2ff7-426a-8041-ddf588d2ad0e
md"""
##### Consideraciones del modelo:
Este tercer modelo que se enfoca en la velocidad de propagación de un mensaje, considerando solo dos estados: informed (mensaje recibido) e uninformed (mensaje no recibido). Este modelo simplificado nos permitirá observar cómo se propaga un único mensaje a través de la red.

1. Solo dos estados: informed y uninformed.

2. Consideramos el parámetro `spread_probability` en la estructura Agent. Este parámetro ahora representa la probabilidad de que un agente decida compartir el mensaje con sus vecinos.

3. Implementamos la función `attempt_spread!` para reflejar este cambio. Ahora, cuando un agente informado intenta compartir el mensaje, usa su spread_probability para decidir si lo hace o no.

4. Actualizamos la función `simulate_step!` para que todos los agentes informados intenten compartir el mensaje con todos sus vecinos en cada paso.

5. Ajustamos las funciones de simulación y visualización para reflejar estos cambios.
"""

# ╔═╡ 9e8e54b5-9d00-45fc-b85a-530e764797f1
md"""
Algunas cosas por ver:

- Cómo la distribución de las probabilidades de propagación afecta la velocidad general de propagación del mensaje.
- Si hay un umbral crítico de probabilidad de propagación por debajo del cual el mensaje no se propaga eficazmente.
- Cómo la estructura de la red interactúa con las probabilidades de propagación individuales.
- Si emergen "super-propagadores" (nodos que son particularmente efectivos en propagar el mensaje debido a su alta probabilidad de propagación y/o su posición en la red).
"""

# ╔═╡ 8b0b1feb-70e6-4b94-8a94-5f02c57d9478
md"""
##### Implementación:
"""

# ╔═╡ 724482f0-79ff-4b04-b444-9a112507a6c4
md"""
Definimos los posibles estados de cada individuo/agente, usamos un tipo enumerado `State` para representar los posibles estados de los agentes.
"""

# ╔═╡ 626eea65-2145-4f3f-b7e6-9ee380ab93a4
@enum State3 informed uninformed

# ╔═╡ 56298e40-4ca2-4482-bd88-5af7d8bae6ec
md"""
Definimos la estructura que representa a un agente, esta cuenta con un id, el estado y la probabilidad que tiene el agente de esparcir el mensaje:
"""

# ╔═╡ eb34d030-362f-4102-b2a3-a3d9c59cb85a
mutable struct Agent3
    id::Int
    state::State3
    spread_probability::Float64  # Probabilidad de decidir esparcir el mensaje
end

# ╔═╡ 22575662-b6b3-4aba-8591-496afda01c28
md"""
Definimos la estructura que representará la red social para este modelo:
"""

# ╔═╡ f9a500c6-2964-4a89-ac8e-45bc4995c60e
struct SocialNetwork3
    graph::SimpleGraph
    agents::Vector{Agent3}
end

# ╔═╡ 783fedfd-b56b-4bb6-8a55-2a720fde0819
md"""
Definimos la siguiente función para simular el envío del mensaje desde un agente informado a uno no informado:
"""

# ╔═╡ 8d0dbb6a-7acc-4108-a971-fd996377b0d2
function attempt_spread!(sender::Agent3, receiver::Agent3)
    if sender.state == informed && receiver.state == uninformed
        if rand() < sender.spread_probability
            receiver.state = informed
        end
    end
end

# ╔═╡ 269de262-67d7-4189-8f4c-4924a43ffbad
md"""
La siguiente función nos permite inicializar la red social:
"""

# ╔═╡ ab070e63-d000-41f4-8b18-bd6f288a82a1
function socialNetwork3(num_agents::Int, spread_probability_range::Tuple{Float64,Float64})
    graph = barabasi_albert(num_agents, 3)
    agents = [Agent3(i, uninformed, rand(Uniform(spread_probability_range...))) for i in 1:num_agents]
    SocialNetwork3(graph, agents)
end

# ╔═╡ 453a1530-dbc3-423f-8b3d-f231c3920ad7
md"""
La siguiente función sirve para establecer los nodos semilla:
"""

# ╔═╡ 078e3d4a-a97d-4775-a437-b9887dd1103e
function set_seed_node3!(network::SocialNetwork3, seed::Int)
    network.agents[seed].state = informed
end

# ╔═╡ 3999ca6f-887e-4d3b-a614-a5388c3a1d0d
md"""
Para simular un paso de la cadena. En este todos los agentes informados intentan compartir el mensaje con cada uno de sus vecinos.
"""

# ╔═╡ 1688787b-baab-43d9-9fb7-623ff90406be
function simulate_step3!(network::SocialNetwork3)
    for agent in network.agents
        if agent.state == informed
            for neighbor_id in neighbors(network.graph, agent.id)
                attempt_spread!(agent, network.agents[neighbor_id])
            end
        end
    end
end

# ╔═╡ 15680aea-dfbe-4024-99ba-dd28750579fa
md"""
Para contar el número de agentes informados:
"""

# ╔═╡ 27061bba-b758-4a98-8378-54891d387f37
function count_informed(network::SocialNetwork3)
    count(agent -> agent.state == informed, network.agents)
end

# ╔═╡ 1ff46e75-07b9-4076-949d-476fc53843f9
md"""
Para correr la simulación:
"""

# ╔═╡ 6690ab8a-7589-4be7-b062-b43d6ac8b943
function run_simulation3(num_agents::Int, num_steps::Int, spread_probability_range::Tuple{Float64,Float64}, num_runs::Int)
    results = []
    for _ in 1:num_runs
        network = socialNetwork3(num_agents, spread_probability_range)
        set_seed_node3!(network, 1) 
        run_results = [count_informed(network)]
        for _ in 1:num_steps
            simulate_step3!(network)
            push!(run_results, count_informed(network))
        end
        push!(results, run_results)
    end
    return results
end

# ╔═╡ a98c1d60-7d84-4077-a2a4-c6056348a9a2
md"""
A continuación, implementamos las funciones para visualizar los resultados:
"""

# ╔═╡ 48dea610-066b-4b7b-abed-8b9beed33e21
function plot_message_spread(results)
    num_steps = length(results[1])
    num_runs = length(results)
    mean_informed = [mean([run[step] for run in results]) for step in 1:num_steps]
    std_informed = [std([run[step] for run in results]) for step in 1:num_steps]
    
    Plots.plot(0:(num_steps-1), mean_informed,
        ribbon=std_informed,
        fillalpha=0.3,
        title="Propagación del Mensaje",
        xlabel="Pasos de simulación",
        ylabel="Número de agentes informados",
        label="Media ± Desv. Estándar",
        legend=:bottomright)
end

# ╔═╡ b2914ec8-7b25-4856-8a4e-d7f8b4ba0fac
function visualize_network_evolution_(simulation_results, network)
    layout = GraphMakie.spring(network.graph)
    fig = Figure(size = (800, 600))
    ax = GraphMakie.Axis(fig[1, 1])
    
    function update_colors(i)
        return [state == informed ? :red : :blue for state in simulation_results[i]]
    end
    
    node_colors = Observable(update_colors(1))
    graphplot!(ax, network.graph,
        layout = layout,
        node_color = node_colors,
        node_size = 15,
        edge_width = 1,
        edge_color = :gray80
    )
    
    legend_elements = [
        MarkerElement(color = :red, marker = :circle, markersize = 15),
        MarkerElement(color = :blue, marker = :circle, markersize = 15)
    ]
    legend_labels = ["Informado", "No informado"]
    Legend(fig[1, 2], legend_elements, legend_labels, "Estado")
    
    ax.title = "Propagación del Mensaje en la Red Social"
    
    slider = PlutoUI.Slider(1:length(simulation_results), default=1, show_value=true)
    
    function update_viz(i)
        node_colors[] = update_colors(i)
    end
    
    return fig, slider, update_viz
end

# ╔═╡ 1aec148a-82b9-4c16-ad03-04da7f1f3770
function run_and_visualize_simulation_(num_agents::Int, num_steps::Int, spread_probability_range::Tuple{Float64,Float64})
    network = socialNetwork3(num_agents, spread_probability_range)
    set_seed_node3!(network, 1)
    simulation_results = [[agent.state for agent in network.agents]]
    for _ in 1:num_steps
        simulate_step3!(network)
        push!(simulation_results, [agent.state for agent in network.agents])
    end

	msf = count_messages(simulation_results)
	print("Mensajes enviados: $msf")
    
   fig, slider, update_viz = visualize_network_evolution_(simulation_results, network)
    return fig, slider, update_viz
end

# ╔═╡ 7c2463f4-d028-4999-b8f9-ac0d47e60f4b
sim_results3 = run_simulation3(100, 50, (0.1, 0.5), 100)

# ╔═╡ 43251690-c0b1-4bff-a257-50e2b5707929
plot_message_spread(sim_results3)

# ╔═╡ 2184b6fb-09e2-4ecd-b505-4968153905a8
function count_messages_in_simulation(simulation_results)
    messages = 0
    prev_state = simulation_results[1]
    for state in simulation_results[2:end]
        messages += count(prev_state .!= state)
        prev_state = state
    end
    return messages
end

# ╔═╡ 88c916b1-2dbe-43b3-af8e-229c41390d94
function expected_messages_sent_(results)
	num_runs = length(results)
    message_counts = zeros(Int, num_runs)
    
    for i in 1:num_runs
		message_counts[i] = count_messages_in_simulation(results[i])
    end
        
    expected_messages = mean(message_counts)
    std_dev_messages = std(message_counts)
    
    return expected_messages, minimum(message_counts), maximum(message_counts)
end

# ╔═╡ 6c90e213-9fc9-4578-be21-6136618ab1b0
begin
mean_messages3, min3, max3 = expected_messages_sent_(sim_results3)
    println("Media de mensajes enviados: $(round(mean_messages3, digits=2))")
    println("Rango de mensajes enviados: $(min3) - $(max3)")
end

# ╔═╡ a4be0176-115e-4828-8443-89b1545a4d4b
md"""
Veamos una simulación: (distinta de las obtenidas en el resultado anterior)
"""

# ╔═╡ 65328c7d-f1a7-49d1-84aa-baac3935e1a2
fig3, slider3, update_viz3 = run_and_visualize_simulation_(50, 20, (0.1, 0.5));

# ╔═╡ 0041d51b-7dbc-41de-8f1d-ccc4a0bde9e1
@bind step3 slider3

# ╔═╡ 18726c83-3d71-4a95-9115-dc2d0613016e
begin
	update_viz3(step3)
	fig3
end

# ╔═╡ aa16771e-505c-4287-ad57-27b9833637c1
md"""
----
# Experimentos:
"""

# ╔═╡ 1bd58b7b-9f71-470c-8989-c94eedaaeefc
import DataFrames, CSV

# ╔═╡ 8cce2a8e-3b89-4a85-a26f-a327d8c5c44d
md"""
- Impacto de los tamaños y estructuras de las redes en la difusión de ideas bajo los dos modelos: Creamos una serie de experimentos que varíen estos parámetros y comparen los resultados. 
"""

# ╔═╡ 5d3ae28e-20d7-420a-81f8-e4e3310a6b7c
function calculate_final_percentages(final_state, model_number)
    total_agents = sum(values(final_state))
    if model_number == 1 || model_number == 2
        return (
            phi = 100 * final_state[phi] / total_agents,
            notphi = 100 * final_state[notphi] / total_agents,
            ind = 100 * final_state[ind] / total_agents
        )
    else  # model 3
        informed = count(s -> s == informed, final_state)
        return (
            phi = 100 * informed / total_agents,
            notphi = 0.0,
            ind = 100 * (total_agents - informed) / total_agents
        )
    end
end

# ╔═╡ 04195279-d7c3-4559-ae7a-39898e5c80bf
function create_network(type, size)
    if type == :barabasi_albert
        return barabasi_albert(size, 3)
    elseif type == :erdos_renyi
        return erdos_renyi(size, 6/size)
    elseif type == :watts_strogatz
        return watts_strogatz(size, 6, 0.1)
    else
        error("Tipo de red no soportado")
    end
end

# ╔═╡ 775c0eda-15da-46f4-b9f9-63713f20dfc2
function run_experiment(model_number::Int, network_sizes, network_types, params, num_steps, num_runs)
    results = DataFrames.DataFrame(
        Model = Int[],
        NetworkSize = Int[],
        NetworkType = String[],
        AvgMessagesSent = Float64[],
        FinalPhiPercentage = Float64[],
        FinalNotPhiPercentage = Float64[],
        FinalIndPercentage = Float64[]
    )
    
    for size in network_sizes
        for type in network_types
            messages_sent = []
            phi_percentages = []
            notphi_percentages = []
            ind_percentages = []
            
            for _ in 1:num_runs
                network = create_network(type, size)
                if model_number == 1
                    simulation_result = run_simulation(size, num_steps, params.λ, params.μ, 1)[1]
                elseif model_number == 2
                    simulation_result = run_simulation2(size, num_steps, params.λ_range, params.μ_range, 1)[1]
                else  # model 3
                    simulation_result = run_simulation3(size, num_steps, params.spread_probability_range, 1)[1]
                end
                
                push!(messages_sent, count_messages(simulation_result))
                percentages = calculate_final_percentages(simulation_result[end], model_number)
                push!(phi_percentages, percentages.phi)
                push!(notphi_percentages, percentages.notphi)
                push!(ind_percentages, percentages.ind)
            end
            
            avg_messages = mean(messages_sent)
            avg_phi = mean(phi_percentages)
            avg_notphi = mean(notphi_percentages)
            avg_ind = mean(ind_percentages)
            
            DataFrames.push!(results, (
                model_number,
                size,
                string(type),
                avg_messages,
                avg_phi,
                avg_notphi,
                avg_ind
            ))
        end
    end
    
    return results
end

# ╔═╡ bb02bb8e-d071-4b8a-b501-fd7849d223cc
begin
network_sizes = [100, 200, 300, 400, 500, 600, 700, 800, 900, 1000]
network_types = [:barabasi_albert, :erdos_renyi, :watts_strogatz]
num_steps = 10000
num_runs = 100

params1 = (λ = 0.5, μ = 0.5)
params2 = (λ_range = (0.3, 0.7), μ_range = (0.3, 0.7))
params3 = (spread_probability_range = (0.1, 0.5),)
end

# ╔═╡ 6c79d8b0-5dca-4e77-8472-f2d504f02d84
results_model1 = run_experiment(1, network_sizes, network_types, params1, num_steps, num_runs)

# ╔═╡ d7894131-159c-459f-bb8a-34b2422881e3
results_model2 = run_experiment(2, network_sizes, network_types, params2, num_steps, num_runs)

# ╔═╡ f7df07f5-a36e-498a-856c-66cd5231f888
# results_model3 = run_experiment(3, network_sizes, network_types, params3, num_steps, num_runs)

# ╔═╡ 6c4bd89a-80c3-4a99-96ac-f19b2820e5f1
all_results = vcat(results_model1, results_model2)

# ╔═╡ 655e8679-9465-4d0c-83c2-f935cc59de98
CSV.write("network_impact_results.csv", all_results)

# ╔═╡ 5a3f260a-983a-4f4b-8958-077dd6c716e6
function plot_results(results)
    p1 = Plots.plot(title="Mensajes enviados vs Tamaño de red")
    p2 = Plots.plot(title="Porcentaje final de creencias vs Tamaño de red")
    
    for model in unique(results.Model)
        for type in unique(results.NetworkType)
            data = results[(results.Model .== model) .& (results.NetworkType .== type), :]
            Plots.plot!(p1, data.NetworkSize, data.AvgMessagesSent, 
                  label="Modelo $(model) - $(type)", marker=:circle)
            Plots.plot!(p2, data.NetworkSize, data.FinalPhiPercentage, 
                  label="Modelo $(model) - $(type) - φ", marker=:circle)
            # Plots.plot!(p2, data.NetworkSize, data.FinalNotPhiPercentage, 
                  #label="Modelo $(model) - $(type) - ¬φ", marker=:square)
            # Plots.plot!(p2, data.NetworkSize, data.FinalIndPercentage, 
                  #label="Modelo $(model) - $(type) - ⊥", marker=:diamond)
        end
    end
    
    Plots.xlabel!(p1, "Tamaño de red")
    Plots.ylabel!(p1, "Promedio de mensajes enviados")
    Plots.xlabel!(p2, "Tamaño de red")
    Plots.ylabel!(p2, "Porcentaje final de agentes")
    Plots.ylims!(p2, (0, 100))
    
    Plots.plot(p1, p2, layout=(2,1), size=(800,1000))
end

# ╔═╡ e08d173a-7902-45fa-80e5-dbeed87e401d
plot_results(all_results)

# ╔═╡ eba55624-9dbd-4f42-8b4d-cce1d3380e1a
savefig("network_impact_analysis.png")

# ╔═╡ 1454d276-c0f7-46be-a847-631861fa77a8
md"""
- investigar el impacto de la conectividad inicial de los nodos semilla.
"""

# ╔═╡ 412d86a6-aa9b-462f-8638-b98d2b3ba9de
function select_seed_nodes(network, strategy)
    if strategy == :high_degree
        degrees = degree(network.graph)
        sorted_nodes = sortperm(degrees, rev=true)
        return sorted_nodes[1:2]  # Seleccionar los dos nodos con mayor grado
    elseif strategy == :low_degree
        degrees = degree(network.graph)
        sorted_nodes = sortperm(degrees)
        return sorted_nodes[1:2]  # Seleccionar los dos nodos con menor grado
    elseif strategy == :random
        return rand(1:length(network.agents), 2)  # Seleccionar dos nodos al azar
    end
end


# ╔═╡ 8117c613-fafa-4ca2-9867-146c13a3adeb
function run_experiment_seed_connectivity(model_number::Int, network_sizes, network_types, params, num_steps, num_runs, seed_strategies)
    results = DataFrames.DataFrame(
        Model = Int[],
        NetworkSize = Int[],
        NetworkType = String[],
        SeedStrategy = String[],
        AvgMessagesSent = Float64[],
        FinalPhiPercentage = Float64[],
        FinalNotPhiPercentage = Float64[],
        FinalIndPercentage = Float64[]
    )
    
    for size in network_sizes
        for type in network_types
            for strategy in seed_strategies
                messages_sent = []
                phi_percentages = []
                notphi_percentages = []
                ind_percentages = []
                
                for _ in 1:num_runs
                    if model_number == 1
                        network = socialNetwork(size)
                    elseif model_number == 2
                        network = socialNetwork2(size, params.λ_range, params.μ_range)
                    end
                    
                    seed_nodes = select_seed_nodes(network, strategy)
                    
                    
                    if model_number == 1
						set_seed_nodes!(network, seed_nodes[1], seed_nodes[2])
                        simulation_result = run_simulation(size, num_steps, params.λ, params.μ, 1)[1]
                    elseif model_number == 2
						set_seed_nodes2!(network, seed_nodes[1], seed_nodes[2])
                        simulation_result = run_simulation2(size, num_steps, params.λ_range, params.μ_range, 1)[1]
                    end
                    
                    push!(messages_sent, count_messages(simulation_result))
                    final_state = simulation_result[end]
                    total_agents = sum(values(final_state))
                    push!(phi_percentages, 100 * final_state[phi] / total_agents)
                    push!(notphi_percentages, 100 * final_state[notphi] / total_agents)
                    push!(ind_percentages, 100 * final_state[ind] / total_agents)
                end
                
                DataFrames.push!(results, (
                    model_number,
                    size,
                    string(type),
                    string(strategy),
                    mean(messages_sent),
                    mean(phi_percentages),
                    mean(notphi_percentages),
                    mean(ind_percentages)
                ))
            end
        end
    end
    
    return results
end

# ╔═╡ 48f035ef-6920-4c44-bbfc-e8bdff7eee7d
function plot_results_seed_connectivity(results)
    p1 = Plots.plot(title="Mensajes enviados vs Tamaño de red")
    p2 = Plots.plot(title="Porcentaje final de φ vs Tamaño de red")
    
    for model in unique(results.Model)
        for type in unique(results.NetworkType)
            for strategy in unique(results.SeedStrategy)
                data = results[(results.Model .== model) .& (results.NetworkType .== type) .& (results.SeedStrategy .== strategy), :]
                Plots.plot!(p1, data.NetworkSize, data.AvgMessagesSent, 
                      label="Modelo $(model) - $(type) - $(strategy)", marker=:circle)
                Plots.plot!(p2, data.NetworkSize, data.FinalPhiPercentage, 
                      label="Modelo $(model) - $(type) - $(strategy)", marker=:circle)
            end
        end
    end
    
    Plots.xlabel!(p1, "Tamaño de red")
    Plots.ylabel!(p1, "Promedio de mensajes enviados")
    Plots.xlabel!(p2, "Tamaño de red")
    Plots.ylabel!(p2, "Porcentaje final de agentes con φ")
    
    Plots.plot(p1, p2, layout=(2,1), size=(800,1000))
end

# ╔═╡ d9e6177e-9e5f-4dc4-b641-71ea208f37a7
seed_strategies = [:high_degree, :low_degree, :random]

# ╔═╡ 0a53ccdd-669d-406e-960b-71a2b5c75aa7
begin
params1_ = (λ = 0.5, μ = 0.5)
params2_ = (λ_range = (0.3, 0.7), μ_range = (0.3, 0.7))
end

# ╔═╡ 5e3a9293-68dd-4963-8c89-26857d3b9ae2
results_model1_seed = run_experiment_seed_connectivity(1, network_sizes, network_types, params1_, num_steps, num_runs, seed_strategies)

# ╔═╡ ebaf12c4-cbeb-4cd6-b44b-6055cc481d66
results_model2_seed = run_experiment_seed_connectivity(2, network_sizes, network_types, params2_, num_steps, num_runs, seed_strategies)

# ╔═╡ cc046d8f-25d9-40f8-a843-5c1dbe968808
all_results_seeds = vcat(results_model1_seed, results_model2_seed)

# ╔═╡ ad9c2c81-2b07-4759-aaa6-8680003b2483
CSV.write("seed_connectivity_impact_results.csv", all_results)

# ╔═╡ cbc786ac-8505-4ece-a13b-3937aefc7ac5
plot_results_seed_connectivity(all_results_seeds)

# ╔═╡ f84886b3-c620-4ef9-8856-6f1ac03de662
savefig("seed_connectivity_impact_analysis.png")

# ╔═╡ 2d7e1efc-4bb0-4203-83ab-5e6b72c9bffd
md"""
- Investigar cambio de fases sobre el grafo reticular $k\times k$.
"""

# ╔═╡ 792f0379-6c15-463c-8691-3e51e8f117fc
function create_lattice_graph(n, m)
    # g = Grid([n, m])
	g = barabasi_albert(n*m, 3)
    return Graph(g)
end

# ╔═╡ 6e7a7d2e-deac-4044-941a-78bd2e5cb982
function socialNetworkLattice(n, m)
    graph = create_lattice_graph(n, m)
    agents = [Agent(i, ind) for i in 1:nv(graph)]
    SocialNetwork(graph, agents)
end

# ╔═╡ e1ab8cc1-7074-4f00-a495-c51e1b7e8fdf
function run_simulationLattice(n, m, num_steps, λ, μ, num_runs)
    results = []
    for _ in 1:num_runs
        network = socialNetworkLattice(n, m)
        set_seed_nodes!(network, 50, 59)  # Esquinas opuestas como semillas
        
        for _ in 1:num_steps
            simulate_step!(network, λ, μ)
        end
        
        final_state = count_beliefs(network)
        total_agents = sum(values(final_state))
        push!(results, (
            phi = final_state[phi] / total_agents,
            notphi = final_state[notphi] / total_agents,
            ind = final_state[ind] / total_agents
        ))
    end
    return results
end

# ╔═╡ d6e0d47b-e85f-4f65-8206-c4d90a88831c
function parameter_sweep(n, m, num_steps, λ_range, μ_range, num_runs)
    results = []
    for λ in λ_range
        for μ in μ_range
            sim_results = run_simulationLattice(n, m, num_steps, λ, μ, num_runs)
            avg_results = (
                λ = λ,
                μ = μ,
                phi = mean([r.phi for r in sim_results]),
                notphi = mean([r.notphi for r in sim_results]),
                ind = mean([r.ind for r in sim_results])
            )
            push!(results, avg_results)
        end
    end
    return results
end

# ╔═╡ 1fab02e3-af04-4746-93ad-b9636a18423a
begin
	n, m = 10, 10
	num_stepsL = 1000
	λ_rangeL = 0.0:0.05:1.0
	μ_rangeL = 0.0:0.05:1.0
	num_runsL = 1000
end

# ╔═╡ 0d0486b7-733f-4b80-a6ab-25e3e2a78b53
sweep_results = parameter_sweep(n, m, num_stepsL, λ_rangeL, μ_rangeL, num_runsL)

# ╔═╡ b8d96a6f-372f-4f54-87ea-fe79998ef2f7
function plot_phase_diagram(results)
    λ_values = unique([r.λ for r in results])
    μ_values = unique([r.μ for r in results])
    
    phi_data = [r.phi for r in results]
    phi_matrix = reshape(phi_data, (length(μ_values), length(λ_values)))
    
    Plots.heatmap(λ_values, μ_values, phi_matrix,
            xlabel="λ", ylabel="μ", title="Proporción final de agentes con creencia φ",
            color=:viridis)
end

# ╔═╡ fff84d4a-3c19-4cee-ad08-6c195cb5aac4
plot_phase_diagram(sweep_results)

# ╔═╡ 734eca76-ef16-4ec3-a78b-37eef4b96f38
function find_critical_points(results)
    λ_values = unique([r.λ for r in results])
    μ_values = unique([r.μ for r in results])
    
    critical_points = []
    
    for μ in μ_values
        μ_results = filter(r -> r.μ ≈ μ, results)
        sort!(μ_results, by = r -> r.λ)
        
        for i in 2:length(μ_results)
            if abs(μ_results[i].phi - μ_results[i-1].phi) > 0.1  # Umbral arbitrario
                push!(critical_points, (λ = μ_results[i].λ, μ = μ))
                break
            end
        end
    end
    
    return critical_points
end

# ╔═╡ c4d3b6c3-1ef8-474a-a064-86d5fe3cc999
critical_points = find_critical_points(sweep_results)

# ╔═╡ e4dc1bc9-3214-40c9-9f24-356244d220f4
begin
function run_simulation_fixed_mu(n, m, num_steps, λ, μ, num_runs)
    results = []
    for _ in 1:num_runs
        network = socialNetworkLattice(n, m)
        set_seed_nodes!(network, 1, n*m)
        
        for _ in 1:num_steps
            simulate_step!(network, λ, μ)
        end
        
        final_state = count_beliefs(network)
        total_agents = sum(values(final_state))
        push!(results, final_state[phi] / total_agents)
    end
    return results
end

function parameter_sweep_fixed_mu(n, m, num_steps, λ_range, μ_values, num_runs)
    results = []
    for μ in μ_values
        for λ in λ_range
            sim_results = run_simulation_fixed_mu(n, m, num_steps, λ, μ, num_runs)
            push!(results, (λ = λ, μ = μ, mean_phi = mean(sim_results), var_phi = var(sim_results)))
        end
    end
    return results
end

function find_critical_lambda(results, μ)
    μ_results = filter(r -> r.μ ≈ μ, results)
    sort!(μ_results, by = r -> r.λ)
    
    max_var_index = argmax([r.var_phi for r in μ_results])
    return μ_results[max_var_index].λ
end
end

# ╔═╡ 5e34d4b8-66cb-4342-b793-af2b2e0a2c4b
μ_valuesL = [0.1, 0.3, 0.5, 0.7, 0.9]

# ╔═╡ eabbaa7c-674c-4729-b025-bbf14753852d
sweep_results2 = parameter_sweep_fixed_mu(n, m, num_stepsL, λ_rangeL, μ_valuesL, num_runsL)

# ╔═╡ 8e08d18d-c247-4fa7-8bda-f1133e6610e5
begin
Plots.plot(title="Proporción media de agentes con creencia φ vs λ")
for μ in μ_valuesL
    μ_results = filter(r -> r.μ ≈ μ, sweep_results2)
    Plots.plot!(
        [r.λ for r in μ_results],
        [r.mean_phi for r in μ_results],
        label="μ = $μ"
    )
end
Plots.xlabel!("λ")
Plots.ylabel!("Proporción media de φ")
end

# ╔═╡ d6cb2941-7609-42d1-ae30-7d8140f75865
savefig("mean_phi_vs_lambda.png")

# ╔═╡ 42ee5a07-6dc2-408b-bbe5-f9c4d77e2dfc
begin
# Gráfico de la varianza de la proporción de agentes con creencia φ
Plots.plot(title="Varianza de la proporción de agentes con creencia φ vs λ")
for μ in μ_valuesL
    μ_results = filter(r -> r.μ ≈ μ, sweep_results2)
    Plots.plot!(
        [r.λ for r in μ_results],
        [r.var_phi for r in μ_results],
        label="μ = $μ"
    )
end
Plots.xlabel!("λ")
Plots.ylabel!("Varianza de la proporción de φ")
end

# ╔═╡ 9d301842-a1dc-459f-af06-ef2f06462309
savefig("var_phi_vs_lambda.png")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
ImageMagick = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"

[compat]
CSV = "~0.10.14"
CairoMakie = "~0.12.10"
ColorSchemes = "~3.26.0"
DataFrames = "~1.6.1"
Distributions = "~0.25.111"
FileIO = "~1.16.3"
GraphMakie = "~0.5.12"
Graphs = "~1.11.2"
ImageMagick = "~1.3.1"
Images = "~0.26.1"
Makie = "~0.21.10"
Plots = "~1.40.7"
PlutoUI = "~0.7.60"
StatsPlots = "~0.15.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "fdc920e6c6cb0efce7fdad50d7486b0ced0a272c"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7d5da5dd472490d048b081ca1bda4a7821b06456"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.1.1"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "9b9b347613394885fd1c8c7729bfc60528faa436"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.4"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "3640d077b6dafd64ceb8fd5c1ec76f7ca53bcf76"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.16.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = "CUDSS"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["PrecompileTools", "TranscodingStreams"]
git-tree-sha1 = "014bc22d6c400a7703c0f5dc1fdc302440cf88be"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.0.4"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "f21cfd4950cb9f0587d5067e69405ad2acd27b87"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.6"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9e2a6b69137e6969bab0152632dcb3bc108c8bdd"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+1"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "PrecompileTools", "Static"]
git-tree-sha1 = "5a97e67919535d6841172016c9530fd69494e5ec"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.2.6"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "6c834533dc1fabd820c1db03c839bf97e45a3fab"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.14"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "7b6ad8c35f4bc3bca8eb78127c8b99719506a5fb"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.0"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Cairo_jll", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "3443ecd9d38c1aeb2c6d0fa3a01598a59929da1d"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.12.10"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "a2f1c8c668c8e3cb4cca4e57a8efdb09067bb3fd"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.0+2"

[[deps.CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "71acdbf594aab5bbb2cec89b208c41b4c411e49f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.24.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CloseOpenIntervals]]
deps = ["Static", "StaticArrayInterface"]
git-tree-sha1 = "05ba0d07cd4fd8b7a39541e31a7b0254704ea581"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.13"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "9ebb045901e9bbf58767a9f34ff89831ed711aae"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonWorldInvalidations]]
git-tree-sha1 = "ae52d1c52048455e85a387fbee9be553ec2b68d0"
uuid = "f70d9fcc-98c5-4d4a-abd7-e4cdeebd8ca8"
version = "1.0.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "f9d7112bfff8a19a3a4ea4e03a8e6a91fe8456bf"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.3"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "Random"]
git-tree-sha1 = "88c5695a8d7b23270afe1b6bef8232ac1f201862"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.3.1"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "66c4c81f259586e8f002eacebc177e1fb06363b0"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.11"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "e6c693a0e4394f8fda0e51a5bdf5aef26f8235e9"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.111"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "b3f2ff58735b5f024c392fde763f29b057e4b025"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.8"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

[[deps.Extents]]
git-tree-sha1 = "81023caa0021a41712685887db1fc03db26f41f5"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.4"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "4820348781ae578893311153d69049a93d05f39d"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "5c1d8ae0efc6c2e7b1fc502cbe25def8f661b7bc"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.2+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "2493cdfd0740015955a8e46de4ef28f49460d8bc"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.3"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "532f9126ad901533af1d4f5c198867227a7bb077"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+1"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "8e2d86e06ceb4580110d9e716be26658effc5bfd"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "da121cbdc95b065da07fbb93638367737969693f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.8+0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "59107c179a586f0fe667024c5eb7033e81333271"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.2"

[[deps.GeoInterface]]
deps = ["Extents", "GeoFormatTypes"]
git-tree-sha1 = "5921fc0704e40c024571eca551800c699f86ceb4"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.6"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "b62f2b2d76cee0d61a2ef2b3118cd2a3215d3134"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.11"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43ba3d3c82c18d88471cfd2924931658838c9d8f"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+4"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "7c82e6a6cd34e9d935e9aa4051b66c6ff3af59ba"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.2+0"

[[deps.GraphMakie]]
deps = ["DataStructures", "GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "PolynomialRoots", "SimpleTraits", "StaticArrays"]
git-tree-sha1 = "c8c3ece1211905888da48e16f438af85e951ea55"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.5.12"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ebd18c326fa6cee1efb7da9a3b45cf69da2ed4d9"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.11.2"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "fc713f007cff99ff9e50accba6373624ddd33588"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.11.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.HistogramThresholding]]
deps = ["ImageBase", "LinearAlgebra", "MappedArrays"]
git-tree-sha1 = "7194dfbb2f8d945abdaf68fa9480a965d6661e69"
uuid = "2c695a8d-9458-5d45-9878-1b8a99cf7853"
version = "0.3.1"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "8e070b599339d622e9a081d17230d74a5c473293"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.17"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "7c4195be1649ae622304031ed46a2f4df989f1eb"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.24"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageBinarization]]
deps = ["HistogramThresholding", "ImageCore", "LinearAlgebra", "Polynomials", "Reexport", "Statistics"]
git-tree-sha1 = "f5356e7203c4a9954962e3757c08033f2efe578a"
uuid = "cbc4b850-ae4b-5111-9e64-df94c024a13d"
version = "0.3.0"

[[deps.ImageContrastAdjustment]]
deps = ["ImageBase", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "eb3d4365a10e3f3ecb3b115e9d12db131d28a386"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.12"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "b2a7eaa169c13f5bcae8131a83bc30eff8f71be0"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.2"

[[deps.ImageCorners]]
deps = ["ImageCore", "ImageFiltering", "PrecompileTools", "StaticArrays", "StatsBase"]
git-tree-sha1 = "24c52de051293745a9bad7d73497708954562b79"
uuid = "89d5987c-236e-4e32-acd0-25bd6bd87b70"
version = "0.1.3"

[[deps.ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "08b0e6354b21ef5dd5e49026028e41831401aca8"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.17"

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "PrecompileTools", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "432ae2b430a18c58eb7eca9ef8d0f2db90bc749c"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.8"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "437abb322a41d527c197fa800455f79d414f0a3c"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.8"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils"]
git-tree-sha1 = "8e2eae13d144d545ef829324f1f0a5a4fe4340f3"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.3.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "OpenJpeg_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "8d2e786fd090199a91ecbf4a66d03aedd0fb24d4"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.11+4"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageMorphology]]
deps = ["DataStructures", "ImageCore", "LinearAlgebra", "LoopVectorization", "OffsetArrays", "Requires", "TiledIteration"]
git-tree-sha1 = "6f0a801136cb9c229aebea0df296cdcd471dbcd1"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.4.5"

[[deps.ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "LazyModules", "OffsetArrays", "PrecompileTools", "Statistics"]
git-tree-sha1 = "783b70725ed326340adf225be4889906c96b8fd1"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.7"

[[deps.ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "3ff0ca203501c3eedde3c6fa7fd76b703c336b5f"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.8.2"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "e0884bdf01bbbb111aea77c348368a86fb4b5ab6"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.10.1"

[[deps.Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageBinarization", "ImageContrastAdjustment", "ImageCore", "ImageCorners", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "12fdd617c7fe25dc4a6cc804d657cc4b2230302b"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.26.1"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "be8e690c3973443bec584db3346ddc904d4884eb"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.5"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "10bd689145d2c3b2a9844005d01087cc1194e79e"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.2.1+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"
weakdeps = ["Unitful"]

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

[[deps.IntervalArithmetic]]
deps = ["CRlibm_jll", "MacroTools", "RoundingEmulator"]
git-tree-sha1 = "fe30dec78e68f27fc416901629c6e24e9d5f057b"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.22.16"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"

    [deps.IntervalArithmetic.weakdeps]
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"
weakdeps = ["Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "PrecompileTools", "Requires", "TranscodingStreams"]
git-tree-sha1 = "a0746c21bdc986d0dc293efa6b1faee112c37c28"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.53"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "39d64b09147620f5ffbf6b2d3255be3c901bec63"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.8"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "f389674c99bfcde17dc57454011aa44d5a260a40"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "fa6d0bcff8583bac20f1ffa708c3913ca605c611"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.5"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c84a835e1a09b289ffcd2271bf2a337bbdda6637"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.3+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "7d703202e65efa1369de1279c162b915e245eed1"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.9"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "70c5da094887fd2cae843b8db33920bac4b6f07d"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "a9eaadb366f5493a5654e843864c13d8b107548c"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.17"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "9fd170c4bbfd8b935fdc5f8b7aa33532c991a673"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.11+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fbb1f2bef882392312feb1ede3615ddc1e9b99ed"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.49.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0c4f9c4f1a50d8f35048fa0532dabbadf702f81e"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg"]
git-tree-sha1 = "110897e7db2d6836be22c18bffd9422218ee6284"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.12.0+0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "CloseOpenIntervals", "DocStringExtensions", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "PrecompileTools", "SIMDTypes", "SLEEFPirates", "Static", "StaticArrayInterface", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "8084c25a250e00ae427a379a5b607e7aed96a2dd"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.171"

    [deps.LoopVectorization.extensions]
    ForwardDiffExt = ["ChainRulesCore", "ForwardDiff"]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.LoopVectorization.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "f046ccd0c6db2832a9f639e2c669c6fe867e5f4f"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Dates", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageBase", "ImageIO", "InteractiveUtils", "Interpolations", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "MakieCore", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun", "Unitful"]
git-tree-sha1 = "768151abed75c6cf5be774456ae82bf9bb7274e9"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.21.10"

[[deps.MakieCore]]
deps = ["ColorTypes", "GeometryBasics", "IntervalSets", "Observables"]
git-tree-sha1 = "4b7aa3b9c51d1d9db74e2401dd1d1eaec416ee55"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.8.7"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "e1641f32ae592e415e3dbae7f4a188b5316d4b62"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.6.1"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "1130dbe1d5276cb656f6e1094ce97466ed700e5a"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.MultivariateStats]]
deps = ["Arpack", "Distributions", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "816620e3aac93e5b5359e4fdaf23ca4525b00ddf"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.10.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "91a67b4d73842da90b526011fa85c5c4c9343fe0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.18"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "StaticArrays"]
git-tree-sha1 = "91bb2fedff8e43793650e7a677ccda6e6e6e166b"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.6"
weakdeps = ["Graphs"]

    [deps.NetworkLayout.extensions]
    NetworkLayoutGraphsExt = "Graphs"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "76374b6e7f632c130e78100b166e5a48464256f8"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.4.0+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "ec3edfe723df33528e085e632414499f26650501"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.0"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "6e55c6841ce3411ccb3457ee52fc48cb698d6fb0"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.2.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "7b1a9df27f072ac4c9c7cbe5efb198489258d1f5"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "f202a1ca4f6e165238d8175df63a7e26a51e04dc"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.7"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "645bed98cd47f72f67316fd42fc47dee771aefcd"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.2.2"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PolynomialRoots]]
git-tree-sha1 = "5f807b5345093487f733e520a1b7395ee9324825"
uuid = "3a141323-8675-5d76-9d11-e1df1406c778"
version = "1.0.0"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase"]
git-tree-sha1 = "a14a99e430e42a105c898fcc7f212334bc7be887"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "3.2.4"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "1d587203cf851a51bf1ea31ad7ff89eff8d625ea"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.0"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "994cc27cdacca10e68feb291673ec3a76aa2fae9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays"]
git-tree-sha1 = "5680a9276685d392c87407df00d57c9924d9f11e"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.7.1"
weakdeps = ["RecipesBase"]

    [deps.Rotations.extensions]
    RotationsRecipesBaseExt = "RecipesBase"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "2803cab51702db743f3fda07dd1745aadfbf43bd"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.5.0"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "456f610ca2fbd1c14f5fcf31c6bfadc55e7d66e0"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.43"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ff11acffdb082493657550959d4feb4b6149e73a"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.5"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "79123bc60c5507f035e6d1d9e563bb2971954ec8"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.4.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["CommonWorldInvalidations", "IfElse", "PrecompileTools"]
git-tree-sha1 = "87d51a3ee9a4b0d2fe054bdd3fc2436258db2603"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "1.1.1"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Static"]
git-tree-sha1 = "96381d50f1ce85f2663584c8e886a6ca97e60554"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.8.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StatsPlots]]
deps = ["AbstractFFTs", "Clustering", "DataStructures", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "NaNMath", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "3b1dcbf62e469a67f6733ae493401e53d92ff543"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.15.7"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "f4dc295e983502292c4c3f951dbb4e985e35b3be"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.18"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = "GPUArraysCore"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "eda08f7e9818eb53661b3deb74e3159460dfbc27"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.2"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "bc7fd5c91041f44636b2c134041f7e5263ce58ae"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.10.0"

[[deps.TiledIteration]]
deps = ["OffsetArrays", "StaticArrayInterface"]
git-tree-sha1 = "1176cc31e867217b06928e2f140c90bd1bc88283"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.5.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "e84b3a11b9bece70d14cce63406bbc79ed3464d2"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.2"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d95fe458f26209c66a187b1114df96fd70839efd"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "e7f5b81c65eb858bed630fe006837b935518aca5"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.70"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "1165b0443d0eca63ac1e32b8c0eb69ed2f4f8127"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.3+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e678132f07ddb5bfa46857f0d7620fb9be675d3b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "936081b536ae4aa65415d869287d43ef3cb576b2"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.53.0+0"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d7015d2e18a5fd9a4f47de711837e980519781a4"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.43+1"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7d0ea0f4895ef2f5cb83645fa689e52cb55cf493"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2021.12.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─01a11336-d9f2-4ea3-8f49-8e0c5377a917
# ╠═6a54a62b-732c-4d5a-827e-beca0b6425c8
# ╟─f47e47b8-7f13-4cf3-a017-c2d33550e3fc
# ╟─ee8bfb9a-ad5f-4957-9916-157782181b40
# ╟─f04ed5bd-65a3-49aa-9a00-a72a96379fbb
# ╟─ca9c8488-52ee-426d-a15e-af6eee622c6b
# ╟─5d2f9b3a-c2d3-430c-9efd-fe418123fd69
# ╟─d03e277c-eef0-40cd-8d59-dbbccb328d5b
# ╟─2a8acc84-d044-46ea-9c94-c0abad85600b
# ╠═3ad17618-7348-4345-883b-4055ba3d2f9c
# ╟─f3d9c1fb-b924-43ce-a498-daaa8d3dd48b
# ╠═10ab3b8e-0cfc-4796-97de-94ad03e38020
# ╟─e87e03fe-1728-4784-ba43-953fc424d257
# ╠═4609932c-13e1-4b0e-92a7-83209af85f62
# ╟─cac9f915-b3a6-483b-8adb-27c3d4584b21
# ╠═a6c50d2c-6467-4aa4-bfa3-64b5b61ee632
# ╟─d7962869-7d12-4ca5-9a0b-1f21b05a16ca
# ╠═bba48b66-23ee-4474-963e-cc56df2c1c17
# ╟─a3dfdda7-25fe-42c2-bb3f-f83e4c89d9a8
# ╟─44f648d0-3aac-4428-b408-b545caec064d
# ╠═d156a007-ea53-477a-991a-afe4e8abb049
# ╟─446e25cf-ea39-44cf-8923-8024be3afce0
# ╟─f267b68e-739d-4a04-b3d7-516afeab8b15
# ╠═0c35af1a-5a85-4bf6-b53a-03743043c6fc
# ╟─945fc349-ec9d-4647-982a-195ef6f43a19
# ╟─89dc04cc-4d4e-4bdf-aa2e-20e93da92d30
# ╠═a4a14bb1-a824-4d03-a259-fa44dbe6f2d3
# ╟─440f5307-8ba1-4a29-a58c-55ef16f82959
# ╠═2cfda743-eebb-41be-a7c3-4d77c0fe57fb
# ╟─50d68bba-51ea-4ee8-998e-899bcf10835c
# ╠═be2a095c-f611-4401-a209-808f95d02be7
# ╟─df9e046f-3df8-4c6c-8624-1a671d249943
# ╠═3a5b442a-2f35-4b3b-9bef-dc7386846695
# ╟─3bbc2f23-460f-4e9a-bc76-0d364b8605de
# ╠═4c4d6cb7-caeb-4768-8e89-be9b468a5e9c
# ╠═5fdb4de2-d240-4cd4-9263-7c3334bb30d4
# ╟─5ad8a283-9233-4a1c-a883-89164c5f1ae5
# ╠═f122a536-077e-4dc6-8147-9932728bdb44
# ╠═84512246-1d25-4a9c-b6aa-3e7bf84aa003
# ╟─f49fab3a-3840-41ff-b2ca-81ae2d7ef7b4
# ╠═ef946d84-2f18-467e-a53e-420c7a0be837
# ╠═dd99f468-0208-439f-94a8-ea5dad16519f
# ╟─6f0b5f5c-e92d-4c8f-9299-9dc19f80f2b5
# ╠═60e6038e-38b4-48bf-9ccb-60039a7adab9
# ╟─144d0782-615f-4b1a-b5fe-77ad5cdce738
# ╠═5e2ac555-559c-4228-bb15-a8a9e470bb6f
# ╟─cea801c9-deed-481f-8d4a-70f4bc4bed64
# ╟─bd470321-2fbf-4a2b-a340-81daeea4b9e7
# ╟─948a7137-a636-4379-a130-423872206dd3
# ╟─91c132aa-cb64-4c61-b8a8-dea8d9f99225
# ╟─69f17f3e-ecaa-457d-9b67-8af5826fa3ca
# ╟─3893a15a-b7cd-42f6-946f-3aefc63bd231
# ╟─473e7834-96a7-40a3-a3a8-8838be14c3fb
# ╟─3428a963-ea41-473e-9477-8baf1b9a9632
# ╟─a140845c-7e4d-4465-8691-92684801d7ee
# ╟─a32abcd7-dd97-42c4-98d4-82c1c37001ae
# ╠═dc6056fc-0d2f-476d-abf6-bdf67e4ee81f
# ╟─70d66b1f-fc1c-4146-80c8-f95d8f5e296c
# ╠═45792cdd-5493-4e7d-868a-7ec35798674b
# ╟─90b41932-68a2-4eaa-85a3-e78b339032fb
# ╠═fe740999-0cec-4dc6-9944-6d656f1abd6b
# ╟─d16d9230-752d-4f01-a05e-e61b1d93ec89
# ╠═82972001-18b4-456f-b1f7-82092e2575f3
# ╟─c4749612-72e7-48c9-b4ea-d80dee7bfc96
# ╠═15138ee3-a0de-4d9b-8f91-24a9d6ba64cd
# ╟─0d0f64f1-b67c-41b1-86a6-5216da90a31e
# ╠═e581e1c1-b34b-4e05-aa61-bb6bcafeb254
# ╟─93a93b9d-0770-41a1-b13f-5ea0b84aa37a
# ╠═6816f635-89c8-4802-9807-2971be8b6b0f
# ╟─4aafb062-3d21-4605-b29d-c21760e39cb1
# ╠═7aea21e7-2e6e-464b-b2e0-7f3e558ed6e6
# ╠═2c557d4c-de35-4cd6-9e16-ce7f44cb0323
# ╠═c8d2f57b-e640-4888-9322-ecbd2eff551b
# ╠═7ca1ee7e-0d51-4d3b-b651-e779fd81c158
# ╠═c69214f7-0f5d-4162-bc22-b52697f0e327
# ╟─3de17f3d-e297-4c31-b628-2b04102124f6
# ╠═2771ccfc-a23b-4aa1-a37f-529792a33819
# ╟─9ed9b4b1-8b4a-4e05-9409-bf2564a99983
# ╟─bab20706-0ba9-4a80-b72a-3a4baf4d6f7e
# ╟─4785d3de-9b35-4883-b192-efa69389fb0c
# ╟─0da863d5-1e24-4862-b583-c4233c3fdbe6
# ╟─fa4f3c36-2ff7-426a-8041-ddf588d2ad0e
# ╟─9e8e54b5-9d00-45fc-b85a-530e764797f1
# ╟─8b0b1feb-70e6-4b94-8a94-5f02c57d9478
# ╟─724482f0-79ff-4b04-b444-9a112507a6c4
# ╠═626eea65-2145-4f3f-b7e6-9ee380ab93a4
# ╟─56298e40-4ca2-4482-bd88-5af7d8bae6ec
# ╠═eb34d030-362f-4102-b2a3-a3d9c59cb85a
# ╟─22575662-b6b3-4aba-8591-496afda01c28
# ╠═f9a500c6-2964-4a89-ac8e-45bc4995c60e
# ╟─783fedfd-b56b-4bb6-8a55-2a720fde0819
# ╠═8d0dbb6a-7acc-4108-a971-fd996377b0d2
# ╟─269de262-67d7-4189-8f4c-4924a43ffbad
# ╠═ab070e63-d000-41f4-8b18-bd6f288a82a1
# ╟─453a1530-dbc3-423f-8b3d-f231c3920ad7
# ╠═078e3d4a-a97d-4775-a437-b9887dd1103e
# ╟─3999ca6f-887e-4d3b-a614-a5388c3a1d0d
# ╠═1688787b-baab-43d9-9fb7-623ff90406be
# ╟─15680aea-dfbe-4024-99ba-dd28750579fa
# ╠═27061bba-b758-4a98-8378-54891d387f37
# ╟─1ff46e75-07b9-4076-949d-476fc53843f9
# ╠═6690ab8a-7589-4be7-b062-b43d6ac8b943
# ╟─a98c1d60-7d84-4077-a2a4-c6056348a9a2
# ╠═48dea610-066b-4b7b-abed-8b9beed33e21
# ╠═b2914ec8-7b25-4856-8a4e-d7f8b4ba0fac
# ╠═1aec148a-82b9-4c16-ad03-04da7f1f3770
# ╠═7c2463f4-d028-4999-b8f9-ac0d47e60f4b
# ╠═43251690-c0b1-4bff-a257-50e2b5707929
# ╠═2184b6fb-09e2-4ecd-b505-4968153905a8
# ╠═88c916b1-2dbe-43b3-af8e-229c41390d94
# ╠═6c90e213-9fc9-4578-be21-6136618ab1b0
# ╟─a4be0176-115e-4828-8443-89b1545a4d4b
# ╠═65328c7d-f1a7-49d1-84aa-baac3935e1a2
# ╟─0041d51b-7dbc-41de-8f1d-ccc4a0bde9e1
# ╟─18726c83-3d71-4a95-9115-dc2d0613016e
# ╟─aa16771e-505c-4287-ad57-27b9833637c1
# ╠═1bd58b7b-9f71-470c-8989-c94eedaaeefc
# ╟─8cce2a8e-3b89-4a85-a26f-a327d8c5c44d
# ╠═775c0eda-15da-46f4-b9f9-63713f20dfc2
# ╠═5d3ae28e-20d7-420a-81f8-e4e3310a6b7c
# ╠═04195279-d7c3-4559-ae7a-39898e5c80bf
# ╠═bb02bb8e-d071-4b8a-b501-fd7849d223cc
# ╠═6c79d8b0-5dca-4e77-8472-f2d504f02d84
# ╠═d7894131-159c-459f-bb8a-34b2422881e3
# ╠═f7df07f5-a36e-498a-856c-66cd5231f888
# ╠═6c4bd89a-80c3-4a99-96ac-f19b2820e5f1
# ╠═655e8679-9465-4d0c-83c2-f935cc59de98
# ╠═5a3f260a-983a-4f4b-8958-077dd6c716e6
# ╠═e08d173a-7902-45fa-80e5-dbeed87e401d
# ╠═eba55624-9dbd-4f42-8b4d-cce1d3380e1a
# ╟─1454d276-c0f7-46be-a847-631861fa77a8
# ╠═8117c613-fafa-4ca2-9867-146c13a3adeb
# ╠═412d86a6-aa9b-462f-8638-b98d2b3ba9de
# ╠═48f035ef-6920-4c44-bbfc-e8bdff7eee7d
# ╠═d9e6177e-9e5f-4dc4-b641-71ea208f37a7
# ╠═0a53ccdd-669d-406e-960b-71a2b5c75aa7
# ╠═5e3a9293-68dd-4963-8c89-26857d3b9ae2
# ╠═ebaf12c4-cbeb-4cd6-b44b-6055cc481d66
# ╠═cc046d8f-25d9-40f8-a843-5c1dbe968808
# ╠═ad9c2c81-2b07-4759-aaa6-8680003b2483
# ╠═cbc786ac-8505-4ece-a13b-3937aefc7ac5
# ╠═f84886b3-c620-4ef9-8856-6f1ac03de662
# ╟─2d7e1efc-4bb0-4203-83ab-5e6b72c9bffd
# ╠═792f0379-6c15-463c-8691-3e51e8f117fc
# ╠═6e7a7d2e-deac-4044-941a-78bd2e5cb982
# ╠═e1ab8cc1-7074-4f00-a495-c51e1b7e8fdf
# ╠═d6e0d47b-e85f-4f65-8206-c4d90a88831c
# ╠═1fab02e3-af04-4746-93ad-b9636a18423a
# ╠═0d0486b7-733f-4b80-a6ab-25e3e2a78b53
# ╠═b8d96a6f-372f-4f54-87ea-fe79998ef2f7
# ╠═fff84d4a-3c19-4cee-ad08-6c195cb5aac4
# ╠═734eca76-ef16-4ec3-a78b-37eef4b96f38
# ╠═c4d3b6c3-1ef8-474a-a064-86d5fe3cc999
# ╠═e4dc1bc9-3214-40c9-9f24-356244d220f4
# ╠═5e34d4b8-66cb-4342-b793-af2b2e0a2c4b
# ╠═eabbaa7c-674c-4729-b025-bbf14753852d
# ╠═8e08d18d-c247-4fa7-8bda-f1133e6610e5
# ╠═d6cb2941-7609-42d1-ae30-7d8140f75865
# ╠═42ee5a07-6dc2-408b-bbe5-f9c4d77e2dfc
# ╠═9d301842-a1dc-459f-af06-ef2f06462309
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
