/* */

$(document).ready(function() {

Chart.defaults.global.responsive = true;
var options = {
	animateRotate: true
};


var ctx = $("#chartMsgsPerHour").get(0).getContext("2d");
new Chart(ctx, {
	type: 'bar',
	data: dataMsgsPerHour,
	options: options
});

ctx = $("#chartServers").get(0).getContext("2d");
new Chart(ctx, {
	type: 'bar',
	data: dataServers,
	options: options
});

ctx = $("#chartLevels").get(0).getContext("2d");
new Chart(ctx, {
	type: 'polarArea',
	data: dataLevels
});

ctx = $("#chartServersPie").get(0).getContext("2d");
new Chart(ctx, {
	type: 'doughnut',
	data: dataServersPie,
	options: options
});


$('#cloudcontainer').jQCloud(dataCloudWords, {
	autoResize: true
});

});
