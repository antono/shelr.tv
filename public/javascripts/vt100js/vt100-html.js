VT = typeof VT == 'undefined' ? {} : VT;

VT.Canvas = {};

VT.Canvas.HTML = function(el, options) {
    this.container = el;
    this.options = options || {};
    this.cols = this.options.cols || 80;
    this.rows = this.options.rows || 24;
    this.initHtmlElement();
    this.cursorPosition = [0, 0];
    this.defaultState = {
        RM: 2, // keyboard action mode
        SGR: {
            birghtness: 0,
            fgColor: 'n37',
            bgColor: 'n40'
        }
    };
    this.state = this.defaultState;
    this.log = {};
    this.mode = {
        DECTCEM: true
    }
}


VT.Canvas.HTML.prototype.initHtmlElement = function() {
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

VT.Canvas.HTML.prototype.cursorIsAtTheEdge = function(edge, position) {
    var cPos = position || this.cursorPosition;
    switch(edge) {
        case 'top':     return cPos[0] <= 0;
        case 'bottom':  return cPos[0] >= this.rows;
        case 'left':    return cPos[1] <= 0;
        case 'right':   return cPos[1] >= this.cols;
    }
}

VT.Canvas.HTML.prototype.getHtmlOffsets = function() {
    var el = this.element;
    return {
        offsetWidth:    el.offsetWidth,
        offsetHeight:   el.offsetHeight,
        offsetTop:      el.offsetTop,
        offsetLeft:     el.offsetLeft,
        offsetParent:   el.offsetParent
    }
}

VT.Canvas.HTML.prototype.getDisplayLength = function() {
    return ( this.cols * this.rows ); 
}

VT.Canvas.HTML.prototype.cursorOffsetToPosition = function(offset) {
    return [Math.floor(offset / this.cols), offset % this.cols];
}

VT.Canvas.HTML.prototype.cursorPositionToOffset = function(pos) {
    return (pos[0] * this.cols) + pos[1];
}

VT.Canvas.HTML.prototype.getCursorOffset = function() {
    return ((this.cursorPosition[0] + 1) * this.cols) - (this.cols - this.cursorPosition[1]);
}

VT.Canvas.HTML.prototype.getEndOfLineOffset = function() {
    return this.getCursorOffset() + (this.cols - this.cursorPosition[1]) - 1;
}

VT.Canvas.HTML.prototype.cursorNext = function() {
    if (this.cursorIsAtTheEdge('right')) {
        this.NEL();
    } else {
        this.cursorPosition[1] += 1;
    }
}

// NEL — Next Line
// http://vt100.net/docs/vt510-rm/NEL
VT.Canvas.HTML.prototype.NEL = function() {
    if (!this.cursorIsAtTheEdge('bottom')) {
        this.CR();
        this.LF();
    } else {
        this.scrollUp();
    }
    this.clearCursor();
}

// IND — Index
// http://vt100.net/docs/vt510-rm/IND
VT.Canvas.HTML.prototype.IND = function() {
    console.log('IND')
    if (!this.cursorIsAtTheEdge('bottom')) {
        this.cursorPosition[0] += 1;
    } else {
        this.scrollUp();
    }
}

VT.Canvas.HTML.prototype.scrollUp = function() {
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
VT.Canvas.HTML.prototype.ED = function(ps) {
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
VT.Canvas.HTML.prototype.VPA = function(coords) {
    //
}

// K = EL — Erase in Line
// http://vt100.net/docs/vt510-rm/EL
VT.Canvas.HTML.prototype.EL = function(mode) {
    var start, stop;
    switch (mode) {
        case 0:
            start = this.getCursorOffset();
            stop  = this.getEndOfLineOffset();
            break;
    }
    //console.log('start: ' + this.cursorOffsetToPosition(start))
    //console.log('stop: ' + this.cursorOffsetToPosition(stop))
    //console.log('EL(' + mode + '): ' + [start, stop]);
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
VT.Canvas.HTML.prototype.DECSTBM = function(tm, bm) {
    this.state.DECSTBM = [tm, bm];
}

// X = ECH — Erase Character
// http://vt100.net/docs/vt510-rm/ECH
VT.Canvas.HTML.prototype.ECH = function(num, cup) {
    this.getCellAt(cup).innerHTML = "&nbsp";
}

VT.Canvas.HTML.prototype.CR = function() {
    this.cursorPosition[1] = 0;
}

VT.Canvas.HTML.prototype.LF = function() {
    this.cursorPosition[0] += 1;
}

// CUP - CUP – CUrsor Position
VT.Canvas.HTML.prototype.CUP = function(coords) {
    //console.log('CUP:' + coords)
    this.cursorPosition = coords;
    this.log.nextChar = true;
}

VT.Canvas.HTML.prototype.getCurrentCell = function(pos) {
    return this.getCellAt(this.cursorPosition);
}

VT.Canvas.HTML.prototype.getCellAt = function(pos) {
    return this.screen[pos[0]][pos[1]].cell;
}

VT.Canvas.HTML.prototype.push = function(chr, sgr) {
    var cell = this.getCurrentCell();
    var pos = this.cursorPosition;
    this.applySGRStyles(cell, sgr);
    cell.innerHTML = chr;
    this.cursorNext();
    this.drawCursor();
}

VT.Canvas.HTML.prototype.drawCursor = function(chr, sgr) {
    var cell = this.getCurrentCell();
    if (this.mode.DECTCEM) cell.classList.add('cursor');
}

VT.Canvas.HTML.prototype.clearCursor = function(chr, sgr) {
    var cursor = this.container.getElementsByClassName('cursor')[0];
    if (cursor) cursor.classList.remove('cursor');
}

// A-D
// Moves the cursor n (default 1) cells in the given direction.
// If the cursor is already at the edge of the screen, this has no effect.

// A - CUU – CUrsor Up
VT.Canvas.HTML.prototype.CUU = function(code) {
    if (!this.cursorIsAtTheEdge('top')) {
        this.cursorPosition[0] -= 1;
    }
}

// B - CUD – CUrsor Down
VT.Canvas.HTML.prototype.CUD = function(code) {
    if (!this.cursorIsAtTheEdge('bottom')) {
        this.cursorPosition[0] += 1;
    }
}

// C - CUF – CUrsor Froward
VT.Canvas.HTML.prototype.CUF = function(code) {
    if (!this.cursorIsAtTheEdge('right')) {
        this.cursorPosition[1] += 1;
    }
}

// D - CUB – CUrsor Back
VT.Canvas.HTML.prototype.CUB = function(code) {
    if (!this.cursorIsAtTheEdge('left')) {
        this.cursorPosition[1] -= 1;
    }
}

VT.Canvas.HTML.prototype.clearSGRStyles = function(cell, grState) {
    cell.removeAttribute('class');
}

VT.Canvas.HTML.prototype.applySGRStyles = function(cell, grState) {
    var attr, el;
    cell.setAttribute('class', '');
    for (key in grState) {
        attr = grState[key];
        switch (key) {
            case 'fgColor':
            case 'bgColor':
                //console.log('->>>' + attr)
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
