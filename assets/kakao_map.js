function inintMap(lat, lng) {
      var mapContainer = document.getElementById('map');
      var mapOption = {
        center: new kakao.maps.LatLng(lat, lng),
        level: 3
      };
      var map = new kakao.maps.Map(mapContainer, mapOption);
      var marker = new kakao.maps.Marker({
        position: new kakao.maps.LatLng(lat, lng)
      });
      marker.setMap(map);

      //map.setDraggable(false);    
      //map.setZoomable(false);  

      console.log("setMap");
      console.log(lat);
      console.log(lng);
    }