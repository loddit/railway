if Meteor.isClient
  width = 1000
  height = 1000
  x = d3.scale.linear().domain([75, 135]).range([0, width])
  y = d3.scale.linear().domain([60,0]).range([0, height])

  d3.json '/railways.json', (railways)->
    window.railways = railways
    svg = d3.select("body").append('svg').attr("width", width).attr("height", height).attr('id','railways')
    lines = svg.selectAll("polyline")
               .data(railways)
    lines.enter().append("svg:polyline")
         .attr("points",(railway,index) -> (_.map(railway.stops,(stop)-> [x(stop.lng),y(stop.lat)].join ',')).join(' '))
         .attr("class",(railway,index) -> railway.number[0])
         .attr("id",(railway,index) -> railway.number)

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
    circles.exit()

if Meteor.isServer
  Meteor.startup ->

