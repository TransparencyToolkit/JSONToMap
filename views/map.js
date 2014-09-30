var map = L.map('map').setView([51.505, -0.09], 2);
L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors', maxZoom: 18 }).addTo(map);

d3.json("out2.json", function(error, data){
    var someFeatures = data;

    function onEachFeature(feature, layer) {
    // does this feature have a property named popupContent?
	if (feature.properties && feature.properties.popupContent) {
            layer.bindPopup(feature.properties.popupContent, {maxHeight: 200, closeButton: true});
	}
    }

    L.geoJson(someFeatures, {
        onEachFeature: onEachFeature
    }).addTo(map);
});
