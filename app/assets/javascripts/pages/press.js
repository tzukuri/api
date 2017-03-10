$(function() {
    $('.continue a').click(function(e) {
        e.preventDefault();
        var link = $(this);
        var article = link.closest('.article');
        var section = article.find('section.bottom');
        section.show();
        link.hide();
    });
});
