var MAPBOX_TOKEN = 'pk.eyJ1Ijoic2FtdHp1a3VyaSIsImEiOiJjaW45cW9qc2QwYzNndHFsd2g4czRpM3ExIn0.BnJfjpwRj2E1cF2bqD42Xw'
var STYLELAYER = 'mapbox://styles/samtzukuri/cin9rek1k00dhbckvr9fezhpl'
var ZOOMLEVEL = 16;

var map = (function () {
  var m = {}

  var glassesMarker = L.icon({
    iconUrl: '',
    iconRetinaUrl: '',
    iconSize: [40, 40]
  });

  m.inject = function(args) {

    var e = args.element;
    var glassesLocation = args.glassesLocation;
    var mainMap;

    L.mapbox.accessToken = MAPBOX_TOKEN

    if (args.glassesLat && args.glassesLon) {
      mainMap = L.mapbox.map('main-map').setView([args.glassesLat, args.glassesLon], ZOOMLEVEL)

      // set the correct marker in the view
      glassesMarker.options.iconUrl = 'images/markers/Marker_' + args.glassesModel + "_" + args.glassesState + ".png";
      glassesMarker.options.iconRetinaUrl = 'images/markers/Marker_' + args.glassesModel + "_" + args.glassesState + "@2x.png"

      L.marker([args.glassesLat, args.glassesLon], {
        icon: glassesMarker
      }).addTo(mainMap)

    } else {
      mainMap = L.mapbox.map(e).setView([-33.852222, 151.210556], ZOOMLEVEL)
    }

    L.mapbox.styleLayer(STYLELAYER).addTo(mainMap);

    // disable controls on the map
    if (args.disableControls) {
      mainMap.touchZoom.disable();
      mainMap.dragging.disable();
      mainMap.doubleClickZoom.disable();
      mainMap.scrollWheelZoom.disable();
      mainMap.boxZoom.disable();
      mainMap.keyboard.disable();
      $(".leaflet-control-zoom").css("visibility", "hidden");
    }

    // hide attribution
    $(".leaflet-control-attribution").css("visibility", "hidden");
  }

  return m;
}());
