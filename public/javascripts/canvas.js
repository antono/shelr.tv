var Canvas = {};

Canvas.HTML = function(el, options) {
    this.container = el;
    this.options = options || {};
    this.cols = this.options.cols || 80;
    this.rows = this.options.rows || 24;
    this.initHtmlElement();
    this.cursorPosition = [0, 0];
    this.defaultState = {
        IRM: 2, // keyboard action mode
        SGR: {
            brightness: 0,
            fgColor: 'n37',
            bgColor: 'n40'
        }
    };
    this.state = JSON.parse(JSON.stringify(this.defaultState));
    this.log = {};
    this.mode = {
        DECTCEM: true
    }
}

Canvas.HTML.prototype.print = function(chr) {
    var cell = this.getCurrentCell();
    var pos = this.cursorPosition;
    this.clearCursor();
    cell.innerHTML = chr;
    this.applySGRStyles(cell);
    this.cursorNext();
    this.drawCursor();
}

//
//
// Legacy
//
//

Canvas.HTML.prototype.initHtmlElement = function() {
    var row, cell;
    this.screen = {};
    this.element = document.createElement('table');
    this.container.appendChild(this.element)
    this.element.setAttribute('border', 0);
    this.element.setAttribute('cellpadding', 0);
    this.element.setAttribute('cellspacing', 0);
    this.element.classList.add('canvas');
    this.element.classList.add('n40');
    this.element.classList.add('b30');
    for (var r = 0; r <= this.rows; r++) {
        row = document.createElement('tr');
        row.setAttribute('id', 'r' + r);
        this.element.appendChild(row);
        this.screen[r] = {}
        for (var c = 0; c <= this.cols; c++) {
            cell = document.createElement('td');
            cell.setAttribute('id', 'r' + r + 'c' + c)
            cell.innerHTML = "&nbsp;";
            row.appendChild(cell);
            this.screen[r][c] = {};
            this.screen[r][c].cell = cell;
        }
    }
}

Canvas.HTML.prototype.cursorIsAtTheEdge = function(edge, position) {
    var cPos = position || this.cursorPosition;
    switch(edge) {
        case 'top':     return cPos[0] <= 0;
        case 'bottom':  return cPos[0] >= this.rows;
        case 'left':    return cPos[1] <= 0;
        case 'right':   return cPos[1] >= this.cols;
    }
}

Canvas.HTML.prototype.getHtmlOffsets = function() {
    var el = this.element;
    return {
        offsetWidth:    el.offsetWidth,
        offsetHeight:   el.offsetHeight,
        offsetTop:      el.offsetTop,
        offsetLeft:     el.offsetLeft,
        offsetParent:   el.offsetParent
    }
}

Canvas.HTML.prototype.getDisplayLength = function() {
    return ( this.cols * this.rows ); 
}

Canvas.HTML.prototype.cursorOffsetToPosition = function(offset) {
    return [Math.floor(offset / this.cols), offset % this.cols];
}

Canvas.HTML.prototype.cursorPositionToOffset = function(pos) {
    return (pos[0] * this.cols) + pos[1];
}

Canvas.HTML.prototype.getCursorOffset = function() {
    return ((this.cursorPosition[0] + 1) * this.cols) - (this.cols - this.cursorPosition[1]);
}

Canvas.HTML.prototype.getEndOfLineOffset = function() {
    return this.getCursorOffset() + (this.cols - this.cursorPosition[1]) - 1;
}

Canvas.HTML.prototype.getStartOfLineOffset = function() {
    return (parseInt(this.getCursorOffset() / this.rows) + 1) * this.cols;
}

Canvas.HTML.prototype.cursorNext = function() {
    if (this.cursorIsAtTheEdge('right')) {
        this.NEL();
    } else {
        this.cursorPosition[1] += 1;
    }
}

// IND — Index
// http://vt100.net/docs/vt510-rm/IND
Canvas.HTML.prototype.IND = function() {
    console.log('IND')
    if (!this.cursorIsAtTheEdge('bottom')) {
        this.cursorPosition[0] += 1;
    } else {
        this.scrollUp();
    }
}

Canvas.HTML.prototype.scrollUp = function() {
    var cell, nextLineCell;
    // scroll up
    for (var r = 0; r <= this.rows; r++) {
        for (var c = 0; c <= this.cols; c++) {
            cell = this.getCellAt([r, c]);
            if (r >= this.rows) {
                this.ECH(1, [r, c])
            } else {
                nextLineCell = this.getCellAt([r + 1, c]);
                cell.setAttribute('class', nextLineCell.classList.toString());
                nextLineCell.setAttribute('class', '');
                cell.innerHTML = nextLineCell.innerHTML;
            }
        }
    }
}

// ED — Erase in Display
// http://vt100.net/docs/vt510-rm/ED
Canvas.HTML.prototype.ED = function(ps) {
    var start, stop, cup, cell;
    switch (ps) {
        case 0:
            start = this.getCursorOffset();
            stop  = this.getDisplayLength();
            break;
        case 1:
            start = 0;
            stop  = this.getCursorOffset();
            break;
        case 2:
            start = 0;
            stop  = this.getDisplayLength();
            break;
    }
    //console.log('ED(' + ps +'): ' + [start, stop]);
    for (var i = start; i < stop; i++) {
        cup  = this.cursorOffsetToPosition(i);
        cell = this.getCellAt(cup);
        this.ECH(1, cup);
        this.clearSGRStyles(cell);
    }
}

// d = VPA — Vertical Line Position Absolute
// http://vt100.net/docs/vt510-rm/VPA
Canvas.HTML.prototype.VPA = function(colNum) {
  console.log(this.cursorPosition)
  this.cursorPosition[0] = (colNum || 0);
}

// K = EL — Erase in Line
// http://vt100.net/docs/vt510-rm/EL
Canvas.HTML.prototype.EL = function(mode) {
    console.log('EL: ', this.cursorPosition, mode)
    var start, stop;
    switch (mode) {
        case NaN:
        case 0: // cursor to eol
            start = this.getCursorOffset();
            stop  = this.getEndOfLineOffset();
            break;
        case 2: // full line
            start = this.getStartOfLineOffset();
            stop  = this.getEndOfLineOffset();
            break;
    }
    //console.log('start: ' + this.cursorOffsetToPosition(start))
    //console.log('stop: ' + this.cursorOffsetToPosition(stop))
    console.log('EL(' + mode + '): ' + [start, stop]);
    for (var i = start; i < stop; i++) {
        cup  = this.cursorOffsetToPosition(i);
        cell = this.getCellAt(cup);
        this.ECH(1, cup);
        this.clearSGRStyles(cell);
    }
}

// r = DECSTBM — Set Top and Bottom Margins
// This control function sets the top and bottom margins for the
// current page. You cannot perform scrolling outside the margins.
Canvas.HTML.prototype.DECSTBM = function(values) {
    this.state.DECSTBM = [values[0], values[1]]; // [topMargin, bottomMargin]
}

// X = ECH — Erase Character
// http://vt100.net/docs/vt510-rm/ECH
Canvas.HTML.prototype.ECH = function(num, cup) {
  console.log('ECH')
  this.getCellAt(cup).innerHTML = "&nbsp";
}

Canvas.HTML.prototype.CR = function() {
  this.cursorPosition[1] = 0;
  this.EL(2)
}

Canvas.HTML.prototype.LF = function() {
  console.log('LF')
  if (!this.cursorIsAtTheEdge('bottom')) {
    this.cursorPosition[0] += 1;
  } else {
    console.log('LF: scroll')
    this.scrollUp();
  }
}

// NEL — Next Line
// http://vt100.net/docs/vt510-rm/NEL
Canvas.HTML.prototype.NEL = function() {
  console.log('NEL')
  this.CR();
  this.LF();
}

// CUP - CUP – CUrsor Position
Canvas.HTML.prototype.CUP = function(coords) {
    //console.log('CUP:' + coords)
    this.cursorPosition = [coords[0] || 0, coords[1] || 0];
    this.log.nextChar = true;
}

Canvas.HTML.prototype.getCurrentCell = function(pos) {
    return this.getCellAt(this.cursorPosition);
}

Canvas.HTML.prototype.getCellAt = function(pos) {
    return this.screen[pos[0]][pos[1]].cell;
}

Canvas.HTML.prototype.push = function(chr, sgr) {
    var cell = this.getCurrentCell();
    var pos = this.cursorPosition;
    this.applySGRStyles(cell, sgr);
    cell.innerHTML = chr;
    this.cursorNext();
    this.drawCursor();
}

Canvas.HTML.prototype.drawCursor = function(chr, sgr) {
    var cell = this.getCurrentCell();
    if (this.mode.DECTCEM) cell.classList.add('cursor');
}

Canvas.HTML.prototype.clearCursor = function(chr, sgr) {
    var cursor = this.container.getElementsByClassName('cursor')[0];
    if (cursor) cursor.classList.remove('cursor');
}

// A-D
// Moves the cursor n (default 1) cells in the given direction.
// If the cursor is already at the edge of the screen, this has no effect.

// A - CUU – CUrsor Up
Canvas.HTML.prototype.CUU = function(code) {
    if (!this.cursorIsAtTheEdge('top')) {
        this.cursorPosition[0] -= 1;
    }
}

// B - CUD – CUrsor Down
// Cursor Down P s Times (default = 1) (CUD).
Canvas.HTML.prototype.CUD = function(times) {
  for (var i = 0; i < ( times || 1 ); i++) {
    if (!this.cursorIsAtTheEdge('bottom')) {
        this.cursorPosition[0] += 1;
    }
  }
}

// C - CUF – CUrsor Froward
Canvas.HTML.prototype.CUF = function(code) {
    if (!this.cursorIsAtTheEdge('right')) {
        this.cursorPosition[1] += 1;
    }
}

// D - CUB – CUrsor Back
Canvas.HTML.prototype.CUB = function(code) {
    if (!this.cursorIsAtTheEdge('left')) {
        this.cursorPosition[1] -= 1;
    }
}


// SGR - Select Graphic Rendition
Canvas.HTML.prototype.SGR = function(codes) {
    var sgrCodes = [];
    var sgrCode, cssClass, brightness;
    var canvas = this;

    if (codes.length === 0) {
      canvas.state.SGR = JSON.parse(JSON.stringify(canvas.defaultState.SGR));
      return;
    }

    codes.forEach(function(sgrCode) {
        sgrCode = parseInt(sgrCode);
        switch (sgrCode) {
           case NaN:  canvas.state.SGR = JSON.parse(JSON.stringify(canvas.defaultState)); break;
            case 0:   canvas.state.SGR.brightness = sgrCode;     break;
            case 1:   canvas.state.SGR.brightness = sgrCode;     break;
            case 2:   canvas.state.SGR.faint      = true;        break;
            case 3:   canvas.state.SGR.italic     = true;        break;
            case 4:   canvas.state.SGR.underline  = true;        break;
            case 5:   canvas.state.SGR.blink      = true;        break;
            case 6:   canvas.state.SGR.blinkfast  = true;        break;
            case 7:  // image: Negative
                //debugger;
                console.log('before swap:', canvas.state.SGR.fgColor, canvas.state.SGR.bgColor);
                var fgc, bgc;
                bgc = canvas.state.SGR.fgColor[2];
                fgc = canvas.state.SGR.bgColor[2];
                canvas.state.SGR.fgColor = canvas.state.SGR.fgColor.replaceAt(2, fgc); 
                canvas.state.SGR.bgColor = canvas.state.SGR.bgColor.replaceAt(2, bgc);
                console.log('after swap:', canvas.state.SGR.fgColor, canvas.state.SGR.bgColor);
                break;
            case 8:  break; // Conceal (not widely supported)
            case 9:  break; // Crossed-out (not widely supported)
            case 10: break; // Primary font
            case 22: break; // neither bright, bold nor faint
            case 27: // image positive
                //debugger;
                console.log('before swap:', canvas.state.SGR.fgColor, canvas.state.SGR.bgColor);
                var fgc, bgc;
                bgc = canvas.state.SGR.fgColor[2];
                fgc = canvas.state.SGR.bgColor[2];
                canvas.state.SGR.fgColor = canvas.state.SGR.fgColor.replaceAt(2, fgc); 
                canvas.state.SGR.bgColor = canvas.state.SGR.bgColor.replaceAt(2, bgc);
                console.log('after swap:', canvas.state.SGR.fgColor, canvas.state.SGR.bgColor);
                break;
            case 25:
                canvas.state.SGR.blink = false;
                canvas.state.SGR.blinkfast = false;
                break;
            case 39:
                canvas.state.SGR.fgColor = canvas.defaultState.SGR.fgColor;
                break;
            case 49:
                canvas.state.SGR.bgColor = canvas.defaultState.SGR.bgColor;
                break;
            default:
                if (sgrCode >= 30 && sgrCode <= 37) {
                    canvas.state.SGR.fgColor = (canvas.state.SGR.brightness === 1 ? 'b' : 'n') + sgrCode;
                } else if (sgrCode >= 40 && sgrCode <= 47) {
                    canvas.state.SGR.bgColor = (canvas.state.SGR.brightness === 1 ? 'b' : 'n') + sgrCode;
                }
        }
        sgrCodes.push(sgrCode)
    })

    return sgrCodes;
}

Canvas.HTML.prototype.applySGRStyles = function(cell) {
    var attr, el;
    var grState = this.state.SGR;
    cell.setAttribute('class', '');
    for (key in grState) {
        attr = grState[key];
        switch (key) {
            case 'fgColor':
            case 'bgColor':
              if (attr !== '') cell.classList.add(attr);
              break;
            case 'faint':
            case 'italic':
            case 'underline':
            case 'blink':
            case 'blinkfast':
                cell.classList.add(key);
                break;
        }
    }
}

Canvas.HTML.prototype.clearSGRStyles = function(cell, grState) {
    cell.removeAttribute('class');
}

Canvas.HTML.prototype.DECSET = function(params) {
  // TODO
}

// This why i hate javascript
String.prototype.replaceAt = function(index, char) {
  return this.substr(0, index) + char + this.substr(index+char.length);
}
