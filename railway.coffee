get_train_class = (number) ->
  if number[0] in ['0','1','2','3','4','5','6','7','8','9']
    'N'
  else
    number[0]

if Meteor.isClient
  width = 1200
  height = 800
  x = d3.scale.linear().domain([75, 135]).range([0, width]) #Mercator projection
  y = d3.scale.linear().domain([55, 15]).range([0, height])
  xy = d3.geo.albers().origin([106,44.5]).parallels([29.5,45]).scale(1060) #Albers projection

  d3.json '/railways.json', (railways)->
    window.railways = railways
    svg = d3.select("body").append('svg').attr("width", width).attr("height", height).attr('id','railways')
    lines = svg.selectAll("polyline")
               .data(railways)
    lines.enter().append("svg:polyline")
         .attr("points",(railway,index) -> (_.map(railway.stops,(stop)-> xy([stop.lng,stop.lat]).join ',')).join(' '))
         .attr("class",(railway,index) -> get_train_class(railway.number))
         .attr("id",(railway,index) -> railway.number.split('/')[0])
         .attr("fill","none")

    $('#meta #railways_count').text(railways.length)

  d3.json '/stations.json', (stations)->
    window.stations = stations
    svg = d3.select("body").append('svg').attr("width", width).attr("height", height).attr('id','stations')
    circles = svg.selectAll("circle")
                 .data(stations)

    circles.enter().append("svg:circle")
    .attr("cx",(d,i) -> xy([d.lng,d.lat])[0])
    .attr("cy",(d,i) -> xy([d.lng,d.lat])[1])
    .attr("r",(d,i) -> {capital:2.5,city:1.7,stop:1}[d.type])
    .attr("fill","white")
    .attr("class",(d,i) -> d.type)
    .attr("data-railways",(d,i) -> d.railways.join(',') if d.railways)
    .append("svg:title")
    .text((d,i) -> d.chinese)

    $('#meta #stations_count').text(stations.length)

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

    $('body').delegate 'input[type="checkbox"]','change', (e) ->
      if e.target.checked
         $("polyline." + $(this).val()).show()
      else
         $("polyline." + $(this).val()).hide()


    $('body').delegate '.label','hover', (e) ->
        color = $(this).data('color')
        $(this).attr('style',"background-color: #{color}")

    $('body').delegate '.label','mouseleave', (e) ->
      toggled = $(this).attr('data-toggled')
      if not toggled
        $(this).attr('style','')

    $('body').delegate('.label','click', (e) ->
      toggled = $(this).attr('data-toggled')
      if toggled
        $(this).removeAttr('data-toggled')
        $("polyline." + $(this).parent().find('input[type="checkbox"]').val()).attr('style', "")
      else
        $(this).attr('data-toggled','true')
        color = $(this).data('color')
        $(this).attr('style',"background-color: #{color}")
        $("polyline." + $(this).parent().find('input[type="checkbox"]').val()).attr('style', "stroke: #{color}; opacity: 0.15; z-index:1")
        $(this).parent().find('input[type="checkbox"]').attr('checked','true')
    )


if Meteor.isServer
  Meteor.startup ->

