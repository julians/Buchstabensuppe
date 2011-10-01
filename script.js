try {
    Typekit.load({
      loading: function() {
        // Javascript to execute when fonts start loading
      },
      active: function() {
        $("#top h1").fitText(0.8);
        $("#byline").fitText(2.8);
      },
      inactive: function() {
        // Javascript to execute when fonts become inactive
      }
    })
  } catch(e) {}

$(document).ready(function()
{
    $("#top h1").fitText();
    $("#byline").fitText(2.8);
    $("h1").lettering();
    $("#yeahyeah").lettering();
    apply3dEffect($("h1")[0], 0, 0, 100, 5, false, false, false, false, false);
    
    var tp = getTransformProperty($("h1")[0]);
    if (tp) {

        $("h1 span").each(function (index, letter) {
            $(letter).css({
                "display": "inline-block",
                "position": "relative",
                "top": "0",
                "left": "0",
                "z-index": getRandomInt(1, 99)
            });
            var mult = Math.random() > 0.5 ? 1 : -1;
            letter.style[tp] = "rotate("+getRandomInt(3, 8)*mult+"deg)";
        });
        
        $(".photoStack").each(function (photoStackIndex, photoStack) {
            var height = 0;
            var tallest = null;
            var photoStackChildren = $(photoStack).children(".photo");
            photoStackChildren.each(function (photoIndex, photo) {
                if ($(photo).outerHeight() > height) {
                    height = $(photo).outerHeight();
                    tallest = photo;
                }
                if (photoIndex > 0) {
                    var c = photoIndex%2 ? "l" : "r"
                    var mult = photoIndex%2 ? 1 : -1;
                    photo.style[tp] = "rotate("+getRandomInt(3, 8)*mult+"deg)";
                    $(photo).addClass(c);
                }
                $(photo).css({
                    "position": "absolute",
                    "left": 0,
                    "top": 0,
                    "z-index": photoStackChildren.length-photoIndex
                });
            });
            $(photoStack).css({
                "position": "relative"
            });
            // dreckig
            tallest = tallest.cloneNode(true);
            $(tallest).css({
                "visibility": "hidden",
                "position": "static"
            }).removeClass("photo").addClass("photoDummy");
            $(photoStack).prepend(tallest);
            $(photoStack).find("img").removeAttr("width").removeAttr("height");
        });
        $("body").delegate(".photo", "click", photoStackClick);
    }
});

function photoStackClick (event)
{
    var photoStack = $(this).parent();
    var photosInStack = photoStack.children(".photo").toArray();
    var zIndex = $(this).css("z-index");
    var tp = getTransformProperty($("h1")[0]);
    
    photosInStack.sort(function (a, b) {
        return $(b).css("z-index") - $(a).css("z-index");
    });
    
    var mult = $(photosInStack[photosInStack.length-1]).hasClass("r") ? 1 : -1;
    var c = $(photosInStack[photosInStack.length-1]).hasClass("r") ? "l" : "r";
    var cssTransformProps = "rotate("+getRandomInt(3, 8)*mult+"deg)";
    cssTransformProps += " scale(1.2)";
    cssTransformProps += " translate("+photoStack.width()+"px, -"+photoStack.height()+"px)";
    photosInStack[0].style[tp] = cssTransformProps;
    photosInStack[1].style[tp] = "rotate(0deg)";
    $(photosInStack[0]).addClass(c);
    $(photosInStack[1]).removeClass("l r");
    
    window.setTimeout(function () {
        photosInStack.push(photosInStack.shift());
        for (var i=0; i < photosInStack.length; i++) {
            $(photosInStack[i]).css("z-index", photosInStack.length-i);
        };
        cssTransformProps = "rotate("+getRandomInt(3, 8)*mult+"deg)";
        cssTransformProps += " scale(1)";
        cssTransformProps += " translate(0, 0)";
        photosInStack[photosInStack.length-1].style[tp] = cssTransformProps;
    }, 510);
}

function apply3dEffect(element, h, s, l, depth, startDepthL, endDepthL, startLetterShadow, endLetterShadow, direction)
{
    var shadows = [];
    var depth = depth ? depth : 5;
    var startDepthL = startDepthL ? startDepthL : 0.67;
    var endDepthL = endDepthL ? endDepthL : 0.4;
    var startLetterShadow = startLetterShadow ? startLetterShadow : 0.3;
    var endLetterShadow = endLetterShadow ? endLetterShadow : 0.9;
    for (var i=0; i < depth; i++) {
        shadows[i] = {
            "x": 0,
            "y": i+1,
            "blur": 0,
            "h": h,
            "s": s,
            "l": l*map(i, 0, depth, startDepthL, endDepthL),
            "a": 1
        };
    };
    shadows.push({
        "x": 0,
        "y": depth+1,
        "blur": 1,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(0, 0, 1, startLetterShadow, endLetterShadow)
    });
    shadows.push({
        "x": 0,
        "y": 0,
        "blur": depth,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(0, 0, 1, startLetterShadow, endLetterShadow)
    });
    shadows.push({
        "x": 0,
        "y": depth*0.2,
        "blur": depth*0.6,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(1, 0, 1, startLetterShadow, endLetterShadow)
    });
    shadows.push({
        "x": 0,
        "y": depth*0.6,
        "blur": depth,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(0.5, 0, 1, startLetterShadow, endLetterShadow)
    });
    shadows.push({
        "x": 0,
        "y": depth,
        "blur": depth*2,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(0.75, 0, 1, startLetterShadow, endLetterShadow)
    });
    shadows.push({
        "x": 0,
        "y": depth*2,
        "blur": depth*2,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(0.5, 0, 1, startLetterShadow, endLetterShadow)
    });
    shadows.push({
        "x": 0,
        "y": depth*4,
        "blur": depth*4,
        "h": h,
        "s": s,
        "l": 0,
        "a": map(0.25, 0, 1, startLetterShadow, endLetterShadow)
    });
    for (var i=0; i < shadows.length; i++) {
        shadows[i] = shadows[i]["x"] + "px " + shadows[i]["y"] + "px " + shadows[i]["blur"] + "px hsla(" + shadows[i]["h"] + ", " + shadows[i]["s"] + "%, " + shadows[i]["l"] + "%, " + shadows[i]["a"] + ")";
    };
    var cssString = shadows.join(",");
    $(element).css("text-shadow", cssString);
}

function getTransformProperty(element)
{
    // Note that in some versions of IE9 it is critical that
    // msTransform appear in this list before MozTransform
    var properties = [
        'transform',
        'WebkitTransform',
        'msTransform',
        'MozTransform',
        'OTransform'
    ];
    var p;
    while (p = properties.shift()) {
        if (typeof element.style[p] != 'undefined') {
            return p;
        }
    }
    return false;
}

/**
 * Returns a random number between min and max
 */
function getRandomArbitary (min, max)
{
    return Math.random() * (max - min) + min;
}

/**
 * Returns a random integer between min and max
 * Using Math.round() will give you a non-uniform distribution!
 */
function getRandomInt (min, max)
{
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function map (x, x0, x1, y0, y1)
{
   return y0+((x-x0)*((y1-y0)/(x1-x0)));
}