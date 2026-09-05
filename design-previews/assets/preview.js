/* 预览页共享脚本：向每个 .screen 注入状态栏 / 灵动岛 / Home 指示条 */
(function () {
  var icons =
    /* 蜂窝信号 */
    '<svg width="19" height="12" viewBox="0 0 19 12" fill="none">' +
    '<rect x="0" y="7.5" width="3.4" height="4.5" rx="1" fill="currentColor"/>' +
    '<rect x="5" y="5" width="3.4" height="7" rx="1" fill="currentColor"/>' +
    '<rect x="10" y="2.5" width="3.4" height="9.5" rx="1" fill="currentColor"/>' +
    '<rect x="15" y="0" width="3.4" height="12" rx="1" fill="currentColor"/></svg>' +
    /* Wi-Fi */
    '<svg width="17" height="12" viewBox="0 0 17 12" fill="none">' +
    '<path d="M8.5 10.6a1.55 1.55 0 1 0 0-3.1 1.55 1.55 0 0 0 0 3.1Z" fill="currentColor"/>' +
    '<path d="M5.1 6.55a4.9 4.9 0 0 1 6.8 0" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>' +
    '<path d="M2.4 3.7a8.7 8.7 0 0 1 12.2 0" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>' +
    /* 电池 */
    '<svg width="27" height="13" viewBox="0 0 27 13" fill="none">' +
    '<rect x="0.6" y="0.6" width="22" height="11.8" rx="3.6" stroke="currentColor" stroke-opacity="0.4" stroke-width="1.1"/>' +
    '<rect x="2.3" y="2.3" width="17.5" height="8.4" rx="2.2" fill="currentColor"/>' +
    '<path d="M24.7 4.4v4.2c1.1-.3 1.8-1.1 1.8-2.1s-.7-1.8-1.8-2.1Z" fill="currentColor" fill-opacity="0.45"/></svg>';

  var statusbar =
    '<div class="island"></div>' +
    '<div class="statusbar">' +
    '<span class="time">9:41</span>' +
    '<span class="sicons">' + icons + '</span>' +
    '</div>' +
    '<div class="homebar"></div>';

  document.querySelectorAll('.screen').forEach(function (screen) {
    screen.insertAdjacentHTML('beforeend', statusbar);
  });

  /* 截图用：?zoom=N；zoom 施加在 .stage 整体上（缩放子空间内排版，不会横向溢出），
     隐藏标注只保留纯净手机屏，配合 4 列网格 + 超宽视口一次截取整套方案 */
  var zoom = parseFloat(new URLSearchParams(location.search).get('zoom') || '0');
  if (zoom > 0) {
    var style = document.createElement('style');
    style.textContent =
      'body{margin:0;overflow:hidden;}' +
      '.stage{zoom:' + zoom + ';grid-template-columns:repeat(4,417px);gap:24px;justify-content:start;padding:14px 16px 18px;max-width:none;}' +
      '.device-col{max-width:none;}' +
      '.screen-no,.caption{display:none;}' +
      '.scheme-nav,.hero,.panel,.footnote{display:none;}' +
      /* 截图时定格动画，保证光标/呼吸点始终可见 */
      '.caret{animation:none !important;opacity:1 !important;}' +
      '.pulse{animation:none !important;opacity:1 !important;}';
    document.head.appendChild(style);
  }
})();
