root = exports ? this

root.getTime = (d) ->
    d ||= new Date()
    return d.getTime()/1000.0
root.bpmRatio = (base, tgt) ->
    1 + ((tgt-base)/base)

root.measureSize = (bpm) ->
    4*60/bpm

root.measureAtTime = (timedelta, bpm) ->
    1 + timedelta / measureSize(bpm)

root.measurePartToFloat = (measure, part) ->
    measure + (part-1)/4.0

root.measureFloatToParts = (measure) ->
    m = Math.floor(measure)
    d = measure-m
    [m, Math.floor(Math.floor(d*40)/10.0) + 1]




root.startOfMeasure = (measure, part, bpm) ->
    (measureSize(bpm) * (measurePartToFloat(measure, part) - 1))
