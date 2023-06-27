module CreatureJl

using LinearAlgebra

mutable struct Creature
    x::Float64
    y::Float64
    speed::Float64
    age::Float64
    ate_food::Bool
    L::Int64

    function Creature(speed, age, ate_food, L)
        new(rand(1:L), rand(1:L), speed, age, ate_food, L)
    end
end

# speed mutations
function mutate!(creature::Creature)
    if rand() > 0.5  # the speed has equal of chance of increasing or decreasing
        creature.speed += 0.5
    else
        creature.speed -= 0.5
    end
end

function my_sigmoid(num::Real)  # to be used in plague!()
    n = num / 100000
    return n / (1 + abs(n))
end

function plague!(liszt)  # based on how large the population is, plague!() kills off a part of the population
    plague_prob = my_sigmoid(length(liszt))

    if plague_prob > rand()

        death_toll = Int64(round((length(liszt))^(my_sigmoid(length(liszt)))))
        for i in 1:death_toll
            splice!(liszt, i)
        end

    end

end

function move!(creature::Creature, delx, dely)  # move a small step in the direction of neareset food
    n = norm([delx, dely])
    creature.x += creature.speed * (delx / n)  # greater the speed, larger the step
    creature.y += creature.speed * (dely / n)
end

function reproduce(creature::Creature)  # make offsprings only after eating food
    if creature.ate_food
        return Creature(creature.speed, 0, false, creature.L)
    end
end

function eat_food!(creature::Creature)
    creature.ate_food = true
end

function age!(creature::Creature, lifespan_const)
    # creature.age = lifespan_const * tan(creature.speed) # can use all sorts of relations, but the will have to tweak lifespan_const to a resonable number
    creature.age = lifespan_const * (creature.speed)^(2)  # eg: with lifespan_const=1 and the above tan relation the population just dies off cuz mean ages are like 10^-2
end
end
