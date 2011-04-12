var Term = {};

var Term = function(container) {
  var term = this;
  this.parser = new Parser(function(parser, action, chr) {
    term[action](chr);
  });
  this.parser.doDebug = true;
  this.canvas = new Canvas.HTML(container);
}


// VT functions
Term.prototype.print = function(chr) {
  this.canvas.print(chr);
}

// The C0 or C1 control function should be executed, which may have any one
// of a variety of effects, including changing the cursor position, suspending
// or resuming communications or changing the shift states in effect. There
// are no parameters to this action.
//
// http://en.wikipedia.org/wiki/C0_and_C1_control_codes
//
Term.prototype.execute = function(chr) {
  switch (chr) {
    case "\n":
      this.canvas.NEL();
    default:
      console.log('exec not handled: ' + chr + ' int: ' + parseInt(chr).toString());
      break;
  }

}

Term.prototype.csi_dispatch = function(fn) {
  var params = this.parser.params;
  var ichars = this.parser.intermediateChars;
  var qm = ((ichars[0] === '?') ? true : false);
  console.log('csi dispatch: ' + fn + ' int: ' + parseInt(fn).toString());
  console.log(params);

  switch (fn) {
    case 'A': this.CUU(parseInt(code)); break;
    case 'B': this.CUD(parseInt(code)); break;
    case 'C': this.CUF(parseInt(code)); break;
    case 'D': this.CUB(parseInt(code)); break;
    case 'm':
      console.log('SGR: ' + params.join(";") + fn)
      this.canvas.SGR(params);
      break;
    case 'H':
      //console.log(code + command);
      this.CUP(params[0]); break;
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
      console.log(params[0] + fn);
      qm ? this.canvas.DECSET(params[0]) : 1
      break;
    case 'r':
      console.log(code + command);
      this.DECSTBM(code);
      break;
    default:
      console.log('csi_dispatch unhandled: ' + fn);
      console.log('params: ' + fn);
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

Term.prototype.hook = function(chr) { }
Term.prototype.unhook = function(chr) { }
Term.prototype.put = function(chr) { }
Term.prototype.osc_start = function(chr) { }
Term.prototype.osc_put = function(chr) { }
Term.prototype.osc_end = function(chr) { }
Term.prototype.osc_dispatch = function(chr) { }

// Helpers

Term.prototype.clear = function() {
  this.canvas.ED(2);
  this.canvas.CUP([0,0]);
}
Term.prototype.pushChars = function(chars) {
  this.parser.pushChars(chars);
}
