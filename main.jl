include("Food.jl")
include("Creature.jl")

using .FoodJl
using .CreatureJl
using LinearAlgebra
using Statistics
using Plots
default(dpi=310)

const L::Int64 = 600  # box size (change this and the creatues will have to move greater distances to find food, everything will be more dispersed)
const init_pop_number::Int64 = 10  # number of creatures at generation 0
const lifespan_limit::Float64 = 70  # creatures with age greater than this number die
const lifespan_const::Float64 = 1  # proportionality constant for relation between age and speed
const reproduce_rate::Int64 = 2  # offsprings produced for every food eaten
const no_of_generations::Int64 = 2000  # number of generations you want to run the simulation for
const food_per_gen::Int64 = 1  # amount of food droped per generation (right now after the food is eaten it is not removed from the box (i know this stupid (will fix later)))
const init_speed::Float64 = 2  # initial speed of creatures


function main()

    # simulating begins
    function simulate_population(init_pop_number, lifespan_limit, reproduce_rate, no_of_generations, food_per_gen)

        # init creature array
        list_of_creatures = CreatureJl.Creature[]

        # init food array
        list_of_foods = [FoodJl.Food(L) for _ in 1:food_per_gen]

        # init array used to store distances of food from a particular creature
        food_distances = zeros(Float64, food_per_gen)

        # generate the initial population at generation 0
        for _ in 1:init_pop_number
            push!(list_of_creatures, CreatureJl.Creature(init_speed, 0, false, L))
        end

        # init array that stores avg speed of creatures per generation 
        avg_speed_per_gen = zeros(Float64, no_of_generations)

        # init array that stores avg age of creatures per generation
        avg_age_per_gen = zeros(Float64, no_of_generations)

        # init array that stores number of creatures per generation
        population_count = zeros(Float64, no_of_generations)

        # init array that stores the generation number
        gen = zeros(Float64, no_of_generations)

        # init array that tracks the number of offsprings produced per generation
        offsprings_per_gen = zeros(Float64, no_of_generations)


        for i in 1:no_of_generations

            # reset the offspring counter
            offspring_count = 0

            # get the generation number into the generation array
            gen[i] = i

            # get the number of creatures
            population_count[i] = length(list_of_creatures)

            # init array that stores speed of every creatures throughout a single generation
            speed_list = Float64[]

            # init array that stores age of every creatures throughout a single generation
            age_list = Float64[]


            println("entering into generation $i")
            println("==============================")
            println("pop no = $(length(list_of_creatures))")

            # put the food on the table
            for i in 1:food_per_gen
                list_of_foods[i] = FoodJl.Food(L)
            end

            # select a creature from the list_of_creatures
            for creature in list_of_creatures

                # allow to mutate
                CreatureJl.mutate!(creature)

                # find the food distances from the creatures under consideration
                for i in 1:length(list_of_foods)
                    food_distances[i] = norm([(creature.x - list_of_foods[i].x), (creature.y - list_of_foods[i].y)])
                end

                # find the nearest food (in case of only food per generation, this is not needed)
                nearest_food_index = findfirst(x -> x == minimum(food_distances), food_distances)
                nearest_food = list_of_foods[nearest_food_index]

                # if food is within reach, eat it
                if norm((creature.x - nearest_food.x) - (creature.y - nearest_food.y)) <= creature.speed
                    CreatureJl.eat_food!(creature)
                    for _ in 1:reproduce_rate
                        push!(list_of_creatures, CreatureJl.reproduce(creature))
                        offspring_count += 1
                    end

                    # else, move towards the food

                else
                    delx = nearest_food.x - creature.x
                    dely = nearest_food.y - creature.y
                    CreatureJl.move!(creature, delx, dely)
                end


                # increase the age
                CreatureJl.age!(creature, lifespan_const)

                # append speed and age into their respective arrays
                push!(speed_list, creature.speed)
                push!(age_list, creature.age)
            end

            # append offspring count, avg age and avg speed into their respective arrays
            offsprings_per_gen[i] = offspring_count
            avg_age_per_gen[i] = mean(age_list)
            avg_speed_per_gen[i] = mean(speed_list)

            # remove aged creatures ( for an explanation as to why !isnan() is used, see README)
            list_of_creatures = [creature for creature in list_of_creatures if creature.age < lifespan_limit && !isnan(creature.x) == true && !isnan(creature.y) == true]

            # plague 
            CreatureJl.plague!(list_of_creatures)

        end

        return offsprings_per_gen, avg_age_per_gen, avg_speed_per_gen, gen, population_count
    end

    # collect all the juicy arrays
    offsprings_per_gen, avg_speed_per_gen, avg_age_per_gen, gen, population_count = simulate_population(init_pop_number, lifespan_limit, reproduce_rate, no_of_generations, food_per_gen)

    # plot
    plot(gen, avg_speed_per_gen, linewidth=0.9, color="black", legend=:false, grid=:false, xlabel="generations", ylabel="<speed>")
    savefig("gen vs <speed>.png")

    plot(gen, avg_age_per_gen, linewidth=0.9, color="black", legend=:false, grid=:false, xlabel="generations", ylabel="<age>")
    savefig("gen vs <age>.png")

    plot(gen, population_count, linewidth=0.9, color="black", legend=:false, grid=:false, xlabel="generation", ylabel="population")
    savefig("gen vs pop_count.png")

    plot(gen, offsprings_per_gen, linewidth=0.9, color="black", legend=:false, grid=:false, xlabel="generations", ylabel="offsprings per generation")
    savefig("gen vs offsprings.png")

end

main()
