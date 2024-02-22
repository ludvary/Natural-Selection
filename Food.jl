module FoodJl

mutable struct Food
    x::Int64
    y::Int64
    L::Int64

    function Food(L)
        new(rand(1:L), rand(1:L), L)
    end
end

end
