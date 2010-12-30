VT = typeof VT == 'undefined' ? {} : VT;

VT.ANSI = {
    ESC: String.fromCharCode(0x1B),
    modeBytes: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'S', 'T', 'f', 'm', 'n', 's', 'd', 'u', 'l', 'h', 'c', 'r'],
}

VT.Core = function(canvas, options) {
    this.canvas = canvas;
    this.clear();
    this.options = options || {};
    this.history = [];
    this.inANSISequence = false;
    this.defaultState = {
        cursorPosition: [0, 0],
        DECSTBM: [0, this.rows],
        RM: 2, // keyboard action mode
        SGR: {
            birghtness: 0,
            fgColor: '',
            bgColor: ''
        }
    };
    this.state = this.defaultState;
    this.log = {};
    this.log.stop = 0;
    this.log.ansi = {}
}

VT.Core.prototype.clear = function() {
    this.canvas.ED(2);
    this.canvas.CUP([0,0]);
}

VT.Core.prototype.pushChars = function(chrs) {
    var vt = this;
    chrs.split("").forEach(function(chr){
        vt.pushChar(chr);
    })
}

VT.Core.prototype.pushChar = function(chr) {
    var vt = this;
    if (this.inANSISequence) {
        if (VT.ANSI.modeBytes.indexOf(chr) !== -1) {
            vt.inANSISequence = false;
            vt.processANSICode(this.ANSICode, chr);
        } else if (chr !== '[') {
            vt.ANSICode += chr;
        }
    } else if (chr === VT.ANSI.ESC) {
        vt.ANSICode = "";
        vt.inANSISequence = true;
    } else if (chr === "\n") {
        vt.canvas.NEL();
        //this.log.stop += 1
        //console.log('------------------')
        //if (this.log.stop > 7) { throw 'yo' }
    } else if (chr === "\r") {
        vt.canvas.CR();
    } else {
        //console.log(chr)
        vt.canvas.push(chr, vt.state.SGR);
    }
}

VT.Core.prototype.processANSICode = function(code, command) {
    var code = code.split(";")
    var qm = code[0].charAt(0) === '?';
    switch (command) {
        case 'A': this.CUU(parseInt(code)); break;
        case 'B': this.CUD(parseInt(code)); break;
        case 'C': this.CUF(parseInt(code)); break;
        case 'D': this.CUB(parseInt(code)); break;
        case 'm':
            console.log('SGR: ' + code.join(";") + command)
            this.SGR(code);
            break;
        case 'H':
            //console.log(code + command);
            this.CUP(code); break;
        case 'K':
            //console.log(code + command);
            this.EL(parseInt(code));
            break;
        case 'J':
            //console.log(code + command)
            qm ? code : this.ED(code);
            break;
        case 'c': this.DA1(code); break;
        case 'd': this.VPA(code); break;
        case 'l':
            console.log(code + command);
            qm ? this.DECRST(code) : this.RM(code);
            break;
        case 'h':
            console.log(code + command);
            qm ? this.DECSET(code) : 1
            break;
        case 'r':
            console.log(code + command);
            this.DECSTBM(code); break;
        default:
            console.log('Unhandled: ' + code + command)
            break;
    }
}


//
// Processing ASCI Commands
// Here implemented common code for different VT Canvases (html, clutter, etc)
//

// A-D
// Moves the cursor n (default 1) cells in the given direction.
// If the cursor is already at the edge of the screen, this has no effect.

// A - CUU – CUrsor Up
VT.Core.prototype.CUU = function(times) {
    console.log('CUU')
    if (isNaN(times)) times = 1;
    for (var i = 0; i < times; i++) { this.canvas.CUU() }
}
// B - CUD – CUrsor Down
VT.Core.prototype.CUD = function(times) {
    console.log('CUD')
    if (isNaN(times)) times = 1;
    for (var i = 0; i < times; i++) { this.canvas.CUD() }
}
// C - CUF – CUrsor Froward
VT.Core.prototype.CUF = function(times) {
    console.log('CUF')
    if (isNaN(times)) times = 1;
    for (var i = 0; i < times; i++) { this.canvas.CUF() }
}
// D - CUB – CUrsor Back
VT.Core.prototype.CUB = function(code) {
    console.log('CUB')
    var times = parseInt(code);
    if (isNaN(times)) times = 1;
    for (var i = 0; i < times; i++) { this.canvas.CUB() }
}

// d = VPA — Vertical Line Position Absolute
// http://vt100.net/docs/vt510-rm/VPA
VT.Core.prototype.VPA = function(coords) {
    if (coords.length < 2) { coords.unshift(1) }
    if (isNaN(coords[0])) coords[0] = 1;
    if (isNaN(coords[1])) coords[1] = 1;
    this.canvas.VPA(coords);
}

// l = RM — Reset Mode
// TODO http://vt100.net/docs/vt510-rm/RM
VT.Core.prototype.RM = function(code) {
    var mode = code[0];
    if (isNaN(mode)) mode = this.defaultState.RM;
    this.state.RM = mode;
}

// ?l = DECRST — Reset Mode
VT.Core.prototype.DECRST = function(codes) {
    var code;
    for (idx in codes) {
        console.log(code)
        code = codes[idx].replace(/\?/,'');
        switch(parseInt(code)) {
            case 25:
                console.log('hide cursor');
                // http://vt100.net/docs/vt510-rm/DECTCEM
                this.canvas.mode.DECTCEM = false;
                this.canvas.clearCursor();
                break;
        }
    }
}

// ?h = DECSET
// ggl docs
VT.Core.prototype.DECSET = function(codes) {
    var code;
    for (idx in codes) {
        console.log(codes[idx])
        code = codes[idx].replace(/\?/,'');
        switch(parseInt(code)) {
            case 25:
                this.canvas.mode.DECTCEM = true;
                break;
        }
    }
}


// c = DA1 — Primary Device Attributes
// http://vt100.net/docs/vt510-rm/DA1
VT.Core.prototype.DA1 = function(code) {
    // TODO
}

// J = ED — Erase in Display
// http://vt100.net/docs/vt510-rm/ED
VT.Core.prototype.ED = function(code) {
    console.log('ED')
    var code = parseInt(code);
    if (isNaN(code)) code = 0;
    this.canvas.ED(code);
}

// K = EL — Erase in Line
// http://vt100.net/docs/vt510-rm/EL
VT.Core.prototype.EL = function(ps) {
    console.log('EL')
    if (isNaN(ps)) ps = 0;
    this.canvas.EL(ps);
}


// r = DECSTBM — Set Top and Bottom Margins
// This control function sets the top and bottom margins for the
// current page. You cannot perform scrolling outside the margins.
VT.Core.prototype.DECSTBM = function(code) {
    var tm = parseInt(code[0]);
    var bm = parseInt(code[1]);
    if (isNaN(tm)) tm = 1;
    if (isNaN(bm)) bm = this.rows;
    this.canvas.DECSTBM(tm, bm);
}

// H = CUP – CUrsor Position
VT.Core.prototype.CUP = function(coords) {
    var row = parseInt(coords[0]);
    var col = parseInt(coords[1]);
    if (isNaN(row)) row = 1;
    if (isNaN(col)) col = 1;
    this.canvas.CUP([row-1, col-1]); // 1 based to 0 based
}

// SGR - Select Graphic Rendition
VT.Core.prototype.SGR = function(codes) {
    var sgrCodes = [];
    var sgrCode, cssClass, brightness;
    var vt = this;

    codes.forEach(function(sgrCode) {
        sgrCode = parseInt(sgrCode);
        switch (sgrCode) {
            case NaN: vt.state.SGR = sgr.defaultState.SGR;  break;
            case 0:  vt.state.SGR.brightness = sgrCode;     break;
            case 1:  vt.state.SGR.brightness = sgrCode;     break;
            case 2:  vt.state.SGR.faint      = true;        break;
            case 3:  vt.state.SGR.italic     = true;        break;
            case 4:  vt.state.SGR.underline  = true;        break;
            case 5:  vt.state.SGR.blink      = true;        break;
            case 6:  vt.state.SGR.blinkfast  = true;        break;
            case 7:  break; // mage: Negative
            case 8:  break; // Conceal (not widely supported)
            case 9:  break; // Crossed-out (not widely supported)
            case 10: break; // Primary font
            case 22: break; // neither bright, bold nor faint
            case 25:
                vt.state.SGR.blink = false;
                vt.state.SGR.blinkfast = false;
                break;
            case 39:
                vt.state.SGR.fgColor = vt.defaultState.SGR.fgColor;
                break;
            case 49:
                vt.state.SGR.bgColor = vt.defaultState.SGR.bgColor;
                break;
            default:
                console.log(sgrCode);
                if (sgrCode >= 30 && sgrCode <= 37) {
                    vt.state.SGR.fgColor = (vt.state.SGR.brightness === 1 ? 'b' : 'n') + sgrCode;
                } else if (sgrCode >= 40 && sgrCode <= 47) {
                    vt.state.SGR.bgColor = (vt.state.SGR.brightness === 1 ? 'b' : 'n') + sgrCode;
                }
        }
        sgrCodes.push(sgrCode)
    })

    return sgrCodes;
}
