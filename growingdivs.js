$(document).ready(function() {
	    SetupGrowingDivs();
});

function SetupGrowingDivs() {
	$('div.gist-file').live({
		mouseover: function() {
			$(this).css('z-index', '100');
			$(this).stop().animate({
                                width: 1300,
				overflow: "visible"
			},200);
		},
		mouseleave: function() {
			$(this).stop().animate({
                                width: 640,
				overflow: "hidden"
			},200);
			$(this).css('z-index', '1');
		}				
	});
}
