// loader.js

var cnvdiv = window.document.getElementById("cnvdiv");
var cnv = window.document.getElementById("output_cnv");
var ctx = cnv.getContext('2d');
var the_button = window.document.getElementById("the_button");

ctx.lineWidth = "1";
ctx.strokeStyle = "grey";

var App = {
    zig: null,
    loaded: false,
    array: null,
    img: null,
    left_click_held: false,
    rect_present: false,
    x1: 0,
    y1: 0,
    x2: 0,
    y2: 0,
};

var initialize = function() {
    console.log("Initializing App data");
    var startaddr = App.zig.startAddr();
    var bufsize = App.zig.getSize();
    console.log("Start address: " + startaddr);
    console.log("Buffer size: " + bufsize);
    App.array = new Uint8ClampedArray(
	App.zig.memory.buffer, startaddr, bufsize
    );
    App.img = new ImageData(
	App.array, App.zig.getWidth(), App.zig.getHeight()
    );
    return;
}

var update = function() {
    ctx.putImageData(App.img, 0, 0);
    if (App.rect_present) {
	ctx.beginPath();
	ctx.moveTo(App.x1, App.y1);
	ctx.lineTo(App.x2, App.y1);
	ctx.lineTo(App.x2, App.y2);
	ctx.lineTo(App.x1, App.y2);
	ctx.lineTo(App.x1, App.y1);
	ctx.stroke();
    }
    return;
};

window.document.body.onload = function() {
    console.log("Loading WASM");

    WebAssembly.instantiateStreaming(fetch("main.wasm"), {
    }).then(res => {
	console.log("WASM loaded");
	console.log("Setting canvas resolution")
	var rect = cnvdiv.getBoundingClientRect();

	cnv.width = rect.width;
	cnv.height = rect.height;

	App.zig = res.instance.exports;
	var res = App.zig.init(cnv.width, cnv.height);
	console.log("Memory allocated: " + res);

	if (res == 0) {
	    console.log("Failed to allocate memory");
	    return;
	}
	App.loaded = true;

	// bind an on-click event for the canvas
	cnv.addEventListener('click', (evt) => {
	    console.log(evt);
	    var rect = cnv.getBoundingClientRect();
	    var w_ratio = (rect.width / 480);
	    var h_ratio = (rect.height / 480);
	    var x = evt.clientX - rect.left;
	    var y = evt.clientY - rect.top;
	    var sx = Math.trunc(x / w_ratio);
	    var sy = Math.trunc(y / h_ratio);
	    console.log(rect);
	    console.log({sx: sx, sy: sy});
	    var numc = App.zig.handle_onclick(sx, sy);
	    console.log({num_filled: numc});
	    update();
	});

	cnv.addEventListener('mousedown', (evt) => {
	    if (!App.left_click_held) {
		App.left_click_held = true;

		var rect = cnv.getBoundingClientRect();
		var ex = evt.clientX - rect.left;
		var ey = evt.clientY - rect.top;

		App.x1 = ex;
		App.y1 = ey;
		App.rect_present = true;
	    }
	});

	cnv.addEventListener('mousemove', (evt) => {
	    if (App.left_click_held) {
		var rect = cnv.getBoundingClientRect();
		var ex = evt.clientX - rect.left;
		var ey = evt.clientY - rect.top;

		App.x2 = ex;
		App.y2 = ey;
		update();
	    }
	});

	cnv.addEventListener('mouseup', (evt) => {
	    if (App.left_click_held) {
		App.left_click_held = false;
	    }
	});

	// resize event trigger
	window.addEventListener('resize', (evt) => {
	    var rect = cnvdiv.getBoundingClientRect();
	    console.log("Resize event!");
	    console.log(rect);
	    cnv.width = rect.width;
	    cnv.height = rect.height;
	    if (App.loaded) {
		// do logic here w/ resizing
	    }
	});

	// button event trigger
	the_button.addEventListener('click', (evt) => {
	    console.log("Button got clicked!!!");
	    if (App.loaded) {
		console.log(cnv.width + " x " + cnv.height);
		var res = App.zig.init(cnv.width, cnv.height);
		console.log("Button update: " + res);

		// clear the selection rect
		// by that I mean just boolean it off
		App.rect_present = false;
		initialize();
		update();
	    }
	});

	// post setup initialization / draw
	initialize();
	update();
    });
};

// PWA/service worker related code
if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('/sw.js')
    .then(() => { console.log('Service Worker Registered'); });
}

// end loader.js
