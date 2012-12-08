if Meteor.isClient
  width = 1200
  height = 800
  x = d3.scale.linear().domain([75, 135]).range([0, width])
  y = d3.scale.linear().domain([55,15]).range([0, height])

  d3.json '/railways.json', (railways)->
    window.railways = railways
    svg = d3.select("body").append('svg').attr("width", width).attr("height", height).attr('id','railways')
    lines = svg.selectAll("polyline")
               .data(railways)
    lines.enter().append("svg:polyline")
         .attr("points",(railway,index) -> (_.map(railway.stops,(stop)-> [x(stop.lng),y(stop.lat)].join ',')).join(' '))
         .attr("data-type",(railway,index) -> railway.number[0] if railway.number[0] not in [0,1,2,3,4,5,6,7,8,9])
         .attr("id",(railway,index) -> railway.number.split('/')[0])

  d3.json '/stations.json', (stations)->
    window.stations = stations
    svg = d3.select("body").append('svg').attr("width", width).attr("height", height).attr('id','stations')
    circles = svg.selectAll("circle")
                 .data(stations)

    circles.enter().append("svg:circle")
    .attr("cx",(d,i) -> x(d.lng))
    .attr("cy",(d,i) -> y(d.lat))
    .attr("r",(d,i) -> {capital:3,city:2,stop:1}[d.type])
    .attr("fill","white")
    .attr("class",(d,i) -> d.type)
    .attr("title",(d,i) -> d.chinese)
    .attr("rel","tooltip")
    .attr("data-railways",(d,i) -> d.railways.join(',') if d.railways)

    circles.exit()

   $ ->
     $('body').delegate('circle','click', (e) ->
       station = $(this)
       toggled = station.attr('data-toggled')
       if toggled
         station.removeAttr('data-toggled')
       else
         station.attr('data-toggled','true')
       railway_ids = station.data('railways').split(',') or []
       _.map(railway_ids, (railway_id) ->
         railway_id = railway_id.toString()
         if railway_id
           railway = $("#" + railway_id.split('/')[0])
           if !toggled
             railway.attr('class','highlight')
           else
             railway.attr('class','')

       )
     )
    $('circle').tooltip()

if Meteor.isServer
  Meteor.startup ->

