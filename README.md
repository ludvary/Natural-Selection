# Natural Selection

## A simple implementation of Natural Selection in Julia

### Fixes to do
1) changing, say, speed-age relation requires a manual change in lifespan_const. Changing the reproduction rate requires the manual finetuning of my_sigmoid().
2) right now, the food doesn't go away after it is consumed until the next generation starts.
