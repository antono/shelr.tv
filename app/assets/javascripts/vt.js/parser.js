"use strict";

if (window) {
    window.VT = (typeof VT === 'undefined' ? {} : window.VT);
} else {
    var VT = {};
}

// VT.Parser - an implementation of Paul Williams' DEC compatible state machine parser
// http://vt100.net/emu/dec_ansi_parser

VT.Parser = function(cb, eb) {
    this.MAX_INTERMEDIATE_CHARS = 2;
    this.numIntermediateChars = 0;
    this.intermediateChars = [];
    this.params = [];
    this.state = 'GROUND';
    this.numParams = 0;
    this.ignoreFlagged = false;
    var parser = this;
    this.callback = function(action,chr) {
        cb(parser, action, chr);
    }
    this.errback = eb;
    this.doDebug = false;
}

VT.Parser.prototype.debug = function(data, force) {
  if (this.doDebug) {
    console.log(data);
  } else if (force) {
    console.log(data);
  }
}

// State Definitions
// http://vt100.net/emu/dec_ansi_parser#STATES
if (!window) (VT.transitions = require('./transitions'));

// Action Handling
// http://vt100.net/emu/dec_ansi_parser#ACTIONS
VT.Parser.prototype.handleAction = function(action, chr) {
    //this.debug('Handling action: ' + action + ' with char: ' + chr);
    switch(action) {
        case 'print':
          //console.log('Handling action: ' + action + ' with char: ' + chr);
        case 'execute':
        case 'csi_dispatch':
        case 'hook':
        case 'put':
        case 'unhook':
        case 'osc_start':
        case 'osc_put':
        case 'osc_end':
        case 'esc_dispatch':
          // if (action === 'csi_dispatch') console.log('Handling action: ' + action + ' with char: ' + chr);
          this.callback(action, chr);
          break;
        case 'ignore': break;
        case 'collect':
            this.debug('Intermediate chars number: ' + this.numIntermediateChars);
            if ((this.numIntermediateChars + 1) > this.MAX_INTERMEDIATE_CHARS) {
                this.ignoreFlagged = true;
            } else {
                this.debug('Intermediate char should be added: ' + chr);
                this.intermediateChars[this.numIntermediateChars++] = chr;
            }
            break;
        case 'param':
            //console.log('param: ' + chr);
            if (chr === ';') { // process the param character
                this.numParams++;
                this.params[this.numParams] = "";
            } else { // char is a digit
                if (this.numParams === 0) this.numParams = 1;
                var curPos = this.numParams - 1;
                if (!this.params[curPos]) this.params[curPos] = "";
                this.params[curPos] += chr;
            }
            // console.log('params', this.params)
            break;
        case 'clear':
            this.numIntermediateChars = 0;
            this.numParams = 0;
            this.ignoreFlagged = 0;
            this.params = []
            this.intermediateChars = [];
            break;
        default:
            this.callback('error', chr)
            console.error('Action unhandled', action, chr);
            break;
    }
}

// Changes state of parser:
//
// 1. exit action from old state
// 2. transition action
// 3. entry action to new state
//
VT.Parser.prototype.changeState = function(newState) {
    this.debug("Changing State to: " + newState);
    var exitAction = VT.transitions[this.state].exit;
    this.debug("ExitAction: " + exitAction);
    if (exitAction) this.handleAction(exitAction);
    this.state = newState;
    var entryAction = VT.transitions[newState].entry;
    this.debug("EntryAction: " + entryAction);
    if (entryAction) this.handleAction(entryAction);
}

VT.Parser.prototype.pushChars = function(string) {
    if (string === undefined || string === "") return;
    for (var i = 0; i < string.length; i++) {
        // try {
            this.pushChar(string[i]);
        // } catch(e) {
        //     this.errback();
        //     throw e;
        // }
    }
}

VT.Parser.prototype.pushChar = function(chr) {
    if (chr === undefined) return;

    var transition, action, newState;
    var charCode = chr.charCodeAt(0);
    var parser = this;

    this.debug('Got char: ' + chr);
    this.debug('Current State: ' + this.state);

    transition = VT.transitions['ANYWHERE'][charCode] || VT.transitions[this.state][charCode];

    if (transition) {
      action   = transition[0];
      newState = transition[1];
      if (action)   this.handleAction(action, chr);
      if (newState) this.changeState(newState);
    } else {
      this.handleAction('print', chr);
    }
}

if (!window) module.exports = VT.Parser;
