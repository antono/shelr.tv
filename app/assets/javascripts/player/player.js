"use strict;"

if (window) {
  window.VT = (typeof VT === 'undefined' ? {} : window.VT);
} else {
  var VT = {};
}

VT.Player = function(term) {
  this.term    = term;
  this.data    = null;
  this.timing  = null;
  this.element = document.getElementById('player');
  this.el = $(this.element);
  this.speedup = 1;
  this.currentFrame = 0;
  this.calculateTermSize();
  this.initSpeedControl();
  this.initHover();
  this.initTermContainer();
  this.initHeader();
  this.initProgress();
  this.initControls();
  this.initCmdline();
  this.initExtraTools();
}

VT.Player.prototype.onError = function() {
  this.pause();
  // this.term.clear();
  this.hoverShow();
  this.hover.classList.add('error');
  this.hoverHide = function() {};
  this.hover.innerHTML = "<br/><div class='img'><img src='/assets/harakiri.png' alt='So sorry...'/></div>切腹"
  this.hover.innerHTML += "<p>Sorry we cannot emulate this shellcast in HTML.<br/>" +
    "Use commandline client instead!<br/>" +
    "<span class='donate'> And consider small <a href='http://weusecoins.com' target='_blank'>bitcoin</a> " +
    "donation to fix this: 17tKDsdjKiS9bmnpH93NBeJnykWgLYbntL  </span>  <br/> &darr; &darr; &darr;</p>"
  this.cmdline.classList.remove('hidden');
  this.controls.classList.add('hidden');
}

VT.Player.prototype.initSpeedControl = function() {
  var speed = jQuery('.speed');
  var player = this;
  fdSlider.createSlider({
    inp: document.getElementsByClassName("speed")[0],
    value: 2.5,
    step:0.5,
    maxStep:1,
    min:1,
    max:10,
    animation: 'tween',
    hideInput: true,
    forceValue: true,
    callbacks: {
      update: [function (update) {
        player.speedup = update.value;
      }]
    }
  });
}

VT.Player.prototype.jumpTo = function(percent) {
  var player = this;
  var i;

  this.term.reset();

  this.setProgress(percent);
  for (i = 0; i < percent; i++) {
    if (this.framesByPercent[i]) {
      this.framesByPercent[i].forEach(function(frameNumber) {
        player.term.write(player.frames[frameNumber][1]);
        player.currentFrame = frameNumber;
      });
    }
  }
}

VT.Player.prototype.percentToFrameNumber = function(percent) {
  return this.framesByPercent[percent];
}

VT.Player.prototype.initProgress = function() {
  var player = this;
  this.progress = this.el.find('.progress');
  this.progressBar = this.progress.find('.bar');

  this.progress.click(function(e) {
    var pixPosition = e.pageX - this.offsetLeft;
    var percentPix = $(this).width() / 100;
    var percent = pixPosition / percentPix;
    player.jumpTo(percent);
  })

  this.progress.prop('max', 100);
  this.setProgress(0);
}

VT.Player.prototype.initControls = function() {
  this.controls = this.element.getElementsByClassName('controls')[0];
  this.controls.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.initCmdline = function() {
  this.cmdline = this.element.getElementsByClassName('cmdline')[0];
  this.cmdline.setAttribute("style", "width:" + (this.termWidth - 6) + "px");
  this.cmdline.addEventListener('click', function(e) {
    e.target.select()
  }, true)
}

VT.Player.prototype.calculateTermSize = function() {
  this.termWidth = (this.term.cols * 7);
  this.termHeight = (this.term.rows * 13);
  this.element.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.initHeader = function() {
  this.header = this.element.getElementsByClassName('header')[0];
  this.header.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.initTermContainer = function() {
  var term = document.getElementById('term');
  term.setAttribute("style", "width:" + this.termWidth + "px");
}

VT.Player.prototype.load = function(path) {
  var player = this;
  jQuery.get(path).success(function(resp){
    player.record = resp;
    player.setTiming(player.record.timing);
    player.setData(player.record.typescript);
    player.prepareFrames();
    player.calculateTotalTime();
    player.mapFrameToPercents();
    player.enableButtons();
  }).error(function (resp) {
    console.log("Error downloading record:", resp)
  });
}

VT.Player.prototype.setTiming = function(data) {
  var timing = [];
  data.split("\n").forEach(function(line){
    var timeBytes = line.split(" ");
    timeBytes = [parseFloat(timeBytes[0]), parseInt(timeBytes[1])];
    if (!isNaN(timeBytes[0]) && !isNaN(timeBytes[1])) {
      timing.push(timeBytes);
    }
  })
  this.timing = timing;
}

VT.Player.prototype.setData = function(data) {
  var dArr  = data.split("\n");
  // drop first and last strings
  this.data = dArr.slice(1, dArr.length - 2).join("\n");
  this.data = "\r\n" + this.data + "\n";
}


VT.Player.prototype.calculateTotalTime = function() {
  var totalTime = 0;
  var onePercentTime;

  // Calculating full time and time of 1%
  this.frames.forEach(function(frame) {
    totalTime += frame[0];
  });
  this.totalTime = totalTime;
  this.onePercentTime = totalTime / 100;

  // console.log('total time', this.totalTime);
  // console.log('one percent time', this.onePercentTime);
}

VT.Player.prototype.mapFrameToPercents = function() {
  // Moving all frames to object { percent: [ .. frame numbers .. ] }
  var framesByPercent = {};
  var player = this;
  var frameNumber = 0;
  var currentFrameAtPercent;
  var currentTotalTime = 0;
  this.frames.forEach(function(frame) {
    currentTotalTime += frame[0];
    currentFrameAtPercent = Math.floor(currentTotalTime / player.onePercentTime);
    if (!framesByPercent[currentFrameAtPercent]) {
      framesByPercent[currentFrameAtPercent] = [];
    }
    frame.push(currentFrameAtPercent);
    framesByPercent[currentFrameAtPercent].push(frameNumber);
    frameNumber  += 1;
  });
  this.framesByPercent = framesByPercent;
}

VT.Player.prototype.prepareFrames = function(data) {
  var frames = [];
  var data = this.data;
  var bOffset = 0;

  this.timing.forEach(function(chunk) {
    var bytes = data.slice(bOffset, bOffset += chunk[1]);
    frames.push([chunk[0] * 1000, bytes]);
  })

  this.frames = frames;
}

VT.Player.prototype.enableButtons = function(data) {
  var button;
  var player = this;
  this.buttons = this.element.getElementsByClassName('sc-button');
  for (var i = 0; i < this.buttons.length; i++) {
    button = this.buttons[i];
    button.addEventListener('click', function(ev){
      var action = ev.currentTarget.getAttribute('data-action');
      if (action) player[action]();
    }, true);
    button.removeAttribute('disabled');
  }
}

VT.Player.prototype.play = function() {
  var player = this;
  var button = this.element.getElementsByClassName('toggle')[0];
  button.setAttribute('data-action', 'pause');
  button.getElementsByTagName('img')[0].setAttribute('src', '/assets/term/playback-pause.png');

  player.hoverHide();

  if (player.playing) return;
  if (player.currentFrame == 0) player.term.reset();

  player.playing = true;

  function scheduleChunked(frames) {
    var chunk = frames[player.currentFrame];
    var debug = 0;
    if (chunk && player.playing) {
      player.term.write(chunk[1])
      setTimeout(function() {
        player.currentFrame += 1
        player.setProgress(chunk[2]);
        scheduleChunked(frames);
      }, (chunk[0] / player.speedup));
    } else {
      if (!player.playing) {
        // console.log('paused')
      } else {
        player.currentFrame = 0;
        player.pause();
      }
      player.hoverShow();
    }
  }
  scheduleChunked(player.frames);
}

VT.Player.prototype.pause = function() {
  var button = this.element.getElementsByClassName('toggle')[0];
  button.getElementsByTagName('img')[0].setAttribute('src', '/assets/term/playback-start.png')
  button.setAttribute('data-action', 'play');
  this.playing = false;
}

VT.Player.prototype.toggle = function() {
  this.playing ? this.pause() : this.play();
}

VT.Player.prototype.settings = function() {
  this.cmdline.classList[this.cmdline.classList.contains('hidden') ? 'remove' : 'add']('hidden');
}

VT.Player.prototype.updateTimelinePosition = function(val) {
  this.currentFrame = this.currentFrame + val;
  // TODO: frame -> percent
  // this.progressBar.css("width", ((100.0 / this.frames.length) * this.currentFrame) + '%' );
}

VT.Player.prototype.setProgress = function(val) {
  // this.currentFrame = val; // FIXME percent -> frame
  this.progress.prop('value', val); 
  this.progressBar.css("width", val + '%' );
}

VT.Player.prototype.initExtraTools = function() {
  // Setup widths for comments and everything below terminal screen
  $('.extra-tools, .comments, h2.comm, .comment-form, .embed-area, .embed-code').css('width', this.termWidth);
  $('.comment-form .markItUp').css('width', this.termWidth).css('border', 0);

  // Embed and Share buttons
  $('button.embed').click(function(ev) {
    $('.embed-area').toggle().toggleClass('hidden');
  });
}

VT.Player.prototype.initHover = function(content) {
  // var player = this;
  this.hover = document.createElement('div');
  // this.term.element.appendChild(this.hover);

  // this.vt.canvas.container.addEventListener('mouseout', function(ev) {
  //   if (!player.playing && ev.target.classList.contains('canvas')) {
  //     //console.log(ev.target.classList)
  //     player.hoverShow();
  //   } else {
  //     ev.stopPropagation();
  //   }
  // }, false)

  // this.hover.addEventListener('mouseover', function(ev) {
  //   if (!player.playing)  {
  //     player.hoverHide();
  //   }
  // }, false);
}

VT.Player.prototype.hoverShow = function(content) {
  return true;
  if (player.playing) {
    this.hoverHide();
    return;
  }
  var offsets = this.vt.canvas.getHtmlOffsets();
  var hover  = this.hover;
  hover.classList.remove('disabled');
  hover.style.display    = 'block';
  hover.style.position   = 'absolute';
  hover.style.top    = offsets.offsetTop+5+'px';
  hover.style.left   = offsets.offsetLeft+5+'px';
  hover.style.width  = offsets.offsetWidth-10+'px';
  hover.style.height = offsets.offsetHeight-10+'px';
  hover.setAttribute('id', 'player-hover');
  hover.classList.add('enabled');
}

VT.Player.prototype.hoverHide = function() {
  this.hover.style.width  = 0;
  this.hover.style.height = 0;
  this.hover.classList.remove('enabled');
  this.hover.classList.add('disabled');
  this.hover.innerHTML = ''
}
