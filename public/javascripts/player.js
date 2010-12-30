SC = (typeof SC === 'undefined' ? {} : SC);

Deferred.define(SC);

SC.Player = function(element,vt) {
    this.vt      = vt;
    this.data    = null;
    this.timing  = null;
    this.element = element;
    this.speedup = 0;
    this.initProgress();
    this.initSpeedControl();
    this.initHover();
}

SC.Player.prototype.initSpeedControl = function() {
    var speed = this.element.getElementsByClassName('speed')[0];
    var player = this;
    speed.setAttribute('step', 100);
    speed.setAttribute('min', -500);
    speed.setAttribute('max', +500);
    speed.setAttribute('value', 0);
    speed.addEventListener('change', function(e) {
        player.speedup = (e.target.value * -1);
    })
}

SC.Player.prototype.initProgress = function() {
    this.progress = this.element.getElementsByTagName('progress')[0];
    this.progress.setAttribute('value', 0)
    this.progress.setAttribute("style", "width:" +
        this.vt.canvas.getHtmlOffsets().offsetWidth + "px");
    this.progress.addEventListener('click', function(e) {
        console.log(e)
    })
}

SC.Player.prototype.load = function(path) {
  var player = this;
  SC.next(function() {
    return SC.get(path) 
  }).error(function(error){
    alert(error);
  }).next(function(resp){
    console.log(resp)
    player.record = resp;
    player.setTiming(player.record.timing);
    player.setData(player.record.typescript);
    player.createTimeline();
    player.enableButtons();
  });
}

SC.Player.prototype.setTiming = function(data) {
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

SC.Player.prototype.setData = function(data) {
    var dArr  = data.split("\n");
    // drop first and last strings
    this.data = dArr.slice(1, dArr.length - 2).join("\n");
}

SC.Player.prototype.createTimeline = function(data) {
    var timeline = [];
    var data = this.data;
    var bOffset = 0;

    this.timing.forEach(function(chunk) {
        var bytes = data.slice(bOffset, bOffset += chunk[1]);
        timeline.push([chunk[0] * 1000, bytes]);
    })

    this.timeline = timeline;
    this.progress.setAttribute('max', timeline.length);
    this.setProgress(0);
}

SC.Player.prototype.enableButtons = function(data) {
    var button;
    var player = this;
    this.buttons = this.element.getElementsByTagName('button');
    for (var i = 0; i < this.buttons.length; i++) {
        button = this.buttons[i];
        button.addEventListener('click', function(ev){
            player[ev.target.className]();
        })
        button.removeAttribute('disabled');
    }
}

SC.Player.prototype.play = function() {
    var player = this;
    this.element.getElementsByClassName('toggle')[0].innerHTML = 'pause'
    player.hoverHide();
    if (player.playing) return;
    if (player.timelinePosition == 0) player.vt.clear();

    player.playing = true;

    function scheduleChunked(timeline) {
        var chunk = timeline[player.timelinePosition];
        var debug = 0;
        var txt;
        if (chunk && player.playing) {
            txt = chunk[1];
            player.vt.pushChars(txt)
            setTimeout(function() {
                player.updateScrollPosition(+1);
                scheduleChunked(timeline);
            }, chunk[0] + player.speedup);
        } else {
            if (!player.playing) {
                console.log('paused')
            } else {
                player.timelinePosition = 0;
                player.pause();
            }
            player.hoverShow();
        }
    }
    scheduleChunked(player.timeline);
}

SC.Player.prototype.pause = function() {
    this.element.getElementsByClassName('toggle')[0].innerHTML = 'play'
    this.playing = false;
}

SC.Player.prototype.toggle = function() {
    this.playing ? this.pause() : this.play();
}

SC.Player.prototype.updateScrollPosition = function(val) {
    this.timelinePosition = this.timelinePosition + val;
    this.progress.setAttribute('value', this.timelinePosition);
}

SC.Player.prototype.setProgress = function(val) {
    this.timelinePosition = val;
    this.progress.setAttribute('value', val);
}


SC.Player.prototype.initHover = function(content) {
    var player = this;
    this.hover = document.createElement('div');
    this.vt.canvas.getHtmlOffsets().offsetParent.appendChild(this.hover);
    this.vt.canvas.container.addEventListener('mouseout', function(ev) {
        // FIXME race condition here
        // mostly works but need to be perfect
        if (!player.playing && ev.target.classList.contains('canvas')) {
            //console.log(ev.target.classList)
            player.hoverShow();
        } else {
            ev.stopPropagation();
        }
    })
    this.hover.addEventListener('mouseover', function(ev) {
        if (!player.playing)  {
            player.hoverHide();
        }
    });
}

SC.Player.prototype.hoverShow = function(content) {
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

SC.Player.prototype.hoverHide = function() {
    this.hover.style.width  = 0;
    this.hover.style.height = 0;
    this.hover.classList.remove('enabled');
    this.hover.classList.add('disabled');
}

//
// Utils
//
SC.path = function(id, file) {
    return '/shellcasts/' + id + '/' + (file || '');
}

SC.get = function(path) {
    var req = new XMLHttpRequest(),
        cb = new Deferred();
    req.onreadystatechange = function() {
        if (this.readyState != 4) return;
        if (this.status == 200) {
            cb.call(JSON.parse(this.responseText));
        } else {
            cb.fail(this.responseText);
        }
    }
    req.open('GET', path);
    req.send(null);
    return cb;
}
