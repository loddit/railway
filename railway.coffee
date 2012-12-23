get_train_class = (number) ->
  if number[0] in ['0','1','2','3','4','5','6','7','8','9']
    'N'
  else
    number[0]

add_class = (target,class_name) ->
  classes = (target.attr('class') or '').split(' ')
  if class_name not in classes
    classes.push class_name
    target.attr('class',classes.join(' '))

remove_class = (target,class_name) ->
  classes = (target.attr('class') or '').split(' ')
  if class_name in classes
    classes.pop(class_name)
    target.attr('class',classes.join(' '))

if Meteor.isClient
  width = 1024
  height = 760
  #Mercator projection
  x = d3.scale.linear().domain([75, 135]).range([0, width])
  y = d3.scale.linear().domain([55, 15]).range([0, height])
  #Albers projection
  xy = d3.geo.albers().origin([103,42]).parallels([29.5,33.5]).scale(1150)

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
    .tooltip((d, i) ->
      {
        type: "tooltip",
        text: d.chinese,
        detection: "shape",
        placement: "fixed",
        gravity: "top",
        position: xy([d.lng,d.lat]),
        displacement: [0,-40],
        mousemove: false
      }
    )

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
            add_class(railway,'highlight')
          else
            remove_class(railway,'highlight')
      )
    )

    $('body').delegate 'input[type="checkbox"]','change', (e) ->
      if e.target.checked
         $("polyline." + $(this).val()).css('stroke',$(this).parent().data('color')).each -> add_class($(this),'highlight')
      else
         $("polyline." + $(this).val()).css('stroke','').each -> remove_class($(this),'highlight')

    $('body').delegate 'input[type="checkbox"]','hover', (e) ->
      $(e.target).tooltip('show')

    $('body').delegate 'input[type="text"]','change', (e) ->
      id = $(e.target).val().toUpperCase()
      railway = $("##{id}")
      if railway.length == 1
        $('.chasing').each -> remove_class($(this),'chasing')
        add_class(railway,'chasing')

  Meteor.startup =>
    $('#filters li').each () -> $(this).css('background-color',$(this).data('color'))

if Meteor.isServer
  Meteor.startup ->

