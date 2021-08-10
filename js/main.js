/// Drawing Canvas
// Reference: https://stackoverflow.com/a/30684711
var canvasWidth = 280;
var canvasHeight = 280;

var canvas = document.getElementById('input-canvas');
var rawImage = document.getElementById('canvas-img');

var ctx = canvas.getContext('2d');
ctx.fillStyle = '#000';
ctx.fillRect(0, 0, canvasWidth, canvasHeight);

var pos = { x: 0, y: 0 };

function setPosition(e) {
  var rect = document.getElementById('input-canvas').getBoundingClientRect();
  pos.x = e.clientX - rect.left;
  pos.y = e.clientY - rect.top;
}

function draw(e) {
  // Avoid drawing on mouse click
  if (e.buttons !== 1) return;

  ctx.beginPath();
  ctx.lineWidth = 28;
  ctx.lineCap = 'round';
  ctx.strokeStyle = '#fff';

  ctx.moveTo(pos.x, pos.y);
  setPosition(e);
  ctx.lineTo(pos.x, pos.y);

  ctx.stroke();

  rawImage.src = canvas.toDataURL('image/png');
}

function startDraw() {
  document.addEventListener('mousemove', draw);
  document.addEventListener('mousedown', setPosition);
  document.addEventListener('mouseenter', setPosition);
}

function stopDraw() {
  document.removeEventListener('mousemove', draw);
  document.removeEventListener('mousedown', setPosition);
  document.removeEventListener('mouseenter', setPosition);
}

function clearCanvas() {
  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, canvasWidth, canvasHeight);
}

function readCanvasImage() {
  var rawImg = ctx.getImageData(0, 0, canvasWidth, canvasHeight).data;
  var imgData = new Array(78400); // 280x280

  // All colors are either white or black which is {0, 255},
  // so no need to check RGBA
  for (var i = 0, idx = 0; i < rawImg.length; i += 4, idx++) {
    // Since all drawings are done with white, no need to calculate grayscale value
    // from RGB, so just take R value as the grayscale value.
    // TODO: Is this true? No need to calculate value from all RGBs?
    imgData[idx] = rawImg[i];
  }
  Shiny.setInputValue('canvas_image', imgData);
}

/// Plotting
var countPlot = document.getElementById('count_plot');
var countMatrix = document.getElementById('count_matrix');
var probPlot = document.getElementById('prob_plot');

function hideResultPlots() {
  countPlot.style.display = 'none';
  countMatrix.style.display = 'none';
}

function showResultPlots() {
  countPlot.style.display = 'block';
  countMatrix.style.display = 'block';
}

function hidePrediction() {
  probPlot.style.display = 'none';
}

function showPrediction() {
  probPlot.style.display = 'block';
}

/// Web UI
startDraw();

$('#download-btn-group').tooltip();

// Used when submit drawing to predict
function clickSubmit() {
  stopDraw();
  readCanvasImage();
  hideResultPlots();
  showPrediction();
}

// Reset all states in canvas and plots
function resetAll() {
  startDraw();
  showResultPlots();
  hidePrediction();
  clearCanvas();
}
