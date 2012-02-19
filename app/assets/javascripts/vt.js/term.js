"use strict;"

if (window) {
    window.VT = (typeof VT === 'undefined' ? {} : window.VT);
} else {
    var VT = {};
    VT.Parser = require('vt/parser');
    VT.Canvas = require('vt/canvas');
}

// Term object composed of Parser, Canvas and ANSI sequence handlers...
VT.Term = function(container) {
    var term = this;
    this.parser = new VT.Parser(function(parser, action, chr) {
        term[action](chr);
    });
    this.parser.doDebug = false;
    this.canvas = new VT.Canvas.HTML(container);
    this.doDebug = true;
}

// Debugger :)
VT.Term.prototype.debug = function(message) {
    if (this.doDebug) console.log(message);
}

// VT functions
VT.Term.prototype.print = function(chr) {
    this.canvas.print(chr);
}

// The C0 or C1 control function should be executed, which may have any one
// of a variety of effects, including changing the cursor position, suspending
// or resuming communications or changing the shift states in effect. There
// are no parameters to this action.
//
// http://en.wikipedia.org/wiki/C0_and_C1_control_codes
//
VT.Term.prototype.execute = function(chr) {
    switch (chr) {
    case "\r":
        this.canvas.CR();
        break;
    case "\n":
        this.canvas.LF();
        break;
    default:
        this.debug('Term.execute(char) not handled: ' + chr + ' int: ' + chr);
        break;
    }
}

VT.Term.prototype.esc_dispatch = function(fn) {
    var params = this.parser.params;
    var ichars = this.parser.intermediateChars;
    var qm = ((ichars[0] === '?') ? true : false);
    switch (fn) {
    case 'A': this.CUU(parseInt(code)); break;
    case 'B': // ESC B -- Cursor down.
        this.canvas.CUD(1);
        break;
    case 'M': // ESC M
    default:
        this.debug('ESC dispatch unhandled: ' + fn);
        break;
    }
}

VT.Term.prototype.csi_dispatch = function(fn) {
    var params = this.parser.params;
    var ichars = this.parser.intermediateChars;
    var qm = ((ichars[0] === '?') ? true : false);

    switch (fn) {
    case 'A': this.CUU(parseInt(code)); break;
    case 'B': // Cursor Down param times
        this.canvas.CUD(parseInt(params[0]));
        break;
    case 'C': this.CUF(parseInt(code)); break;
    case 'D': this.CUB(parseInt(code)); break;
    case 'm':
        console.log('SGR: ' + params.join(";") + fn)
        this.canvas.SGR(params);
        break;
    case 'H':
        //console.log(code + command);
        //debugger;
        this.canvas.CUP(params); break;
    case 'K':
        //console.log(code + command);
        this.canvas.EL(parseInt(params[0]));
        break;
    case 'J':
        //debugger;
        qm ? 'FIXME' : this.canvas.ED(parseInt(params[0]));
        break;
    case 'c': this.DA1(code); break;
    case 'd':
        //debugger;
        this.canvas.VPA(parseInt(params[0]));
        break;
    case 'l':
        /// FIXME qm ? this.DECRST(code) : this.canvas.IRM(code);
        break;
    case 'h':
        //console.log(params.join(';') + fn);
        qm ? this.canvas.DECSET(params) : console.error('h unhandled')
        break;
    case 'r':
        //console.log(params, fn);
        // Set Scrolling Region
        this.canvas.DECSTBM(params);
        break;
    default:
        console.error('csi_dispatch unhandled: ' + fn);
        console.error('params: ' + fn);
        break;
    }

    /*
      switch(chr) {
      case '@':
      if (nparam==1) gprintf(" IC: insert %d characters", *parser->params);
      if (nparam==0) gprintf(" IC: insert chars unknown");
      nc();
      break;
      case 'C':
      if (nparam==1)
      gprintf(" RI: move cursor right %d",*parser->params);
      if(nparam==0) gprintf(" RI: move cursor unknown");
      nc();
      break;
      case 'H':
      if(nparam==2) gprintf(" cm: cursor to %d %d", *parser->params,*(parser->params+1));
      if(nparam==1) gprintf(" cm: cursor to %d", *parser->params);
      *  if(nparam==0) gprintf(" ho: cursor to home");
      nc();
      break;
      case 'h':
      if(nparam) {
      switch(*parser->params) {
      case 25:
      gprintf(" ve: 25h cursor normal");
      nc();
      break;
      default:
      gprintf(" CSI_DISPATCH: unknown action for %dh", *parser->params);
      nc();
      break;
      }
      } else {
      gprintf(" CSI_DISPATCH: unknown action for h");
      nc();
      }
      break;

      case 'J':
      gprintf(" cd: clear to end of screen");
      nc();
      break;
      case 'K':
      gprintf(" ce: clear to end of line");
      nc();
      break;
      case 'L':
      if(nparam==1)
      gprintf(" al: insert line at %d",*parser->params);
      if(nparam==0) gprintf(" al: insert line at unknown");
      nc();
      break;
      case 'l':
      if (nparam) {
      switch(*parser->params) {
      case 25:
      gprintf(" ve: 25l cursor invisible");
      nc();
      break;
      default:
      gprintf(" CSI_DISPATCH: unknown action for %dl",
      *parser->params);
      nc();
      break;
      }
      } else {
      gprintf(" CSI_DISPATCH: unknown action for l");
      nc();
      }
      break;
      case 'M':
      if (nparam==1) gprintf(" DL: delete %d lines", *parser->params);
      if (nparam==0) gprintf(" DL: delete lines unknown");
      nc();
      break;
      case 'P':
      if(nparam==1) gprintf(" DC: delete %d characters", *parser->params);
      if(nparam==0) gprintf(" DC: delete chars unknown");
      nc();
      break;
      case 'r':
      if (nparam==2)
      gprintf(" cs: region is line %d to line %d", *parser->params,*(parser->params+1));
      if (nparam==1) gprintf(" cs: region is line %d", *parser->params);
      if (nparam==0) gprintf(" cs: region is unknown");
      nc();
      break;
      default:
      gprintf(" CSI_DISPATCH: unknown action for %x (%c) nparam: %d", ch,ch,nparam);
      nc();
      break;
      }
    */
}

VT.Term.prototype.hook = function(chr) { }
VT.Term.prototype.unhook = function(chr) { }
VT.Term.prototype.put = function(chr) { }
VT.Term.prototype.osc_start = function(chr) { }
VT.Term.prototype.osc_put = function(chr) { }
VT.Term.prototype.osc_end = function(chr) { }
VT.Term.prototype.osc_dispatch = function(chr) { }

// Helpers

VT.Term.prototype.clear = function() {
    this.canvas.ED(2);
    this.canvas.CUP([0,0]);
}

VT.Term.prototype.pushChars = function(chars) {
    this.parser.pushChars(chars);
}

if (!window) module.exports = VT.Term;
