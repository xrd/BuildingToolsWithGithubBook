# var data = {
#   labels : ["January","February","March","April","May","June","July"],
#   datasets : [
#               {
#                 fillColor : "rgba(220,220,220,0.5)",
#                 strokeColor : "rgba(220,220,220,1)",
#                 pointColor : "rgba(220,220,220,1)",
#                 pointStrokeColor : "#fff",
#                 data : [65,59,90,81,56,55,40]
#               },
#               {
#                 fillColor : "rgba(151,187,205,0.5)",
#                 strokeColor : "rgba(151,187,205,1)",
#                 pointColor : "rgba(151,187,205,1)",
#                 pointStrokeColor : "#fff",
#                 data : [28,48,40,19,96,27,100]
#               }
#              ]
# }

require 'tempfile'

file = Tempfile.new(['foo', ".html"], "temp" )
path = file.path
file.unlink
puts "File: #{path}"

doc = <<HTML
<html>
<body>

<canvas id="myChart" width="800" height="400"></canvas>

<script src="/Chart.js"></script>

<script type="text/javascript">
var data = {
  labels : ["January","February","March","April","May","June","July"],
  datasets : [
              {
                fillColor : "rgba(220,220,220,0.5)",
                strokeColor : "rgba(220,220,220,1)",
                pointColor : "rgba(220,220,220,1)",
                pointStrokeColor : "#fff",
                data : [65,59,90,81,56,55,40]
              },
              {
                fillColor : "rgba(151,187,205,0.5)",
                strokeColor : "rgba(151,187,205,1)",
                pointColor : "rgba(151,187,205,1)",
                pointStrokeColor : "#fff",
                data : [28,48,40,19,96,27,100]
              }
             ]
}

//Get the context of the canvas element we want to select
var ctx = document.getElementById("myChart").getContext("2d");
new Chart(ctx).Line(data); //,options);

</script>

</body>
</html>
HTML

File.open path, "w+" do |f|
f.write doc
end

`open http://1234000000486.dev/#{path}`

