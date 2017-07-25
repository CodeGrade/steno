import Terminal from "xterm";
import _ from "underscore";
import socket from "./socket";

var channel;
var term;

function connect() {
  channel = socket.channel("jobs:0", {});
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });
}

$(function() {
  if (!$('#xterm')) {
    return;
  }

  connect();

  channel.on("chunks", resp => {
    term.reset();
    _.each(resp.chunks, cc => {
      cc = cc.replace(/\n/g, "\r\n");
      term.write(cc);
      /*
       _.each(cc.split(/\r?\n/), ll => {
       term.writeln(ll);
       console.log(ll);
       });
       */
    });
  });

  term = new Terminal({
    cursorBlink: false,
    cols: 100,
    rows: 40,
  });
  term.open($('#xterm')[0], false);
  $(function() { term.reset(); });

  window.term = term;
});
