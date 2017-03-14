//= require jquery.justified

$(function() {
    $('#images-container').empty().justifiedImages({
        images : photos,
        rowHeight: 400,
        maxRowHeight: 500,

        thumbnailPath: function(photo, width, height){
            return photo.url;
        },

        getSize: function(photo) {
            return {width: photo.width, height: photo.height};
        },

        margin: 1
    });
});
