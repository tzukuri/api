$(function() {
    $('.continue a').click(function(e) {
        var link = $(this);
        var parent = link.closest('.continue');
        var article = parent.closest('.article');
        var section = article.find('section.bottom');

        // prevent scrolling to the top of the page
        e.preventDefault();

        // show the 'bottom' (expanded) content
        section.show();

        // hide the p element containing the link
        parent.hide();
    });
});
