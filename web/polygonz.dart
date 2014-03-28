import 'dart:html';
import 'dart:math';
import 'dart:js' as js;

//variables
var canvasWidth;
var canvasHeight;
var colors=[""];
int shapeCountX;
int shapeCountY;
var shapeWidth;
var shapeHeight;
var wrapColors;
var distortion;

//constants
int DENSITY_MAX=200;
int SIZE_MAX=10000;
int SHIM = 1; //used to fill in gaps between shapes

//presets
var presetNames = ["iPhone 5", "1080p", "iPhone 4", "iPad","4K","2.5k","720p","Web Tile"];

var presetValues = [["640","1136","10","14"],
                    ["1920","1080","30","14"],
                    ["640","960","10","12"],
                    ["2048","1536","34","20"],
                    ["3840","2160","60","24"],
                    ["2560","1440","40","18"],
                    ["1280","720","20","10"],
                    ["200","200","12","12"]
                    ];

//color swatches
var swatchNames=["Darkness",
                 "Heavy Cream",
                 "Attack of the Mac",
                 "Barcelona",
                 "Blue Humans",
                 "Buried at the Beach",
                 "Raptorize",
                 "Cthulhu Rises",
                 "Boring Volcano",
                 "Light the Sky",
                 "Hackers",
                 "Tracert",
                 "City by Night",
                 "Wicked Witch",
                 "Flying Monkeys",
                 "Searching",
                 "Office Chair in the Clouds",
                 "Born to be a Winner",
                 "1969",
                 "Teapots",
                 "Wordpress"
                 ];
var swatchValues=  ["#444,#000,#040404,#080808,#0c0c0c,#101010,#141414,#181818,#1c1c1c,#202020,#242424,#282828,#2c2c2c,#000,#040404,#080808,#0c0c0c,#101010,#141414,#181818,#1c1c1c,#202020,#242424,#282828,#2c2c2c,#000,#040404,#080808,#0c0c0c,#101010,#141414,#181818,#1c1c1c,#202020,#242424,#282828,#2c2c2c",
                    "#fff,#faf9f8,#f7f7f6,#f6f5f4,#f4f3f2,#f2f1f0,#eeedec,#eae9e8,#faf9f8,#f7f7f6,#f6f5f4,#f4f3f2,#f2f1f0,#eeedec,#eae9e8,#faf9f8,#f7f7f6,#f6f5f4,#f4f3f2,#f2f1f0,#eeedec,#eae9e8",
                    "#445555,#889999,#4499DD,#DDDDDD,#AACCCC",
                    "#27282D,#474D4B,#F54296,#E0F635,#FDFFF7",
                    "#294052,#447294,#8FBCDB,#F4D6BC,#F8E4CC",
                    "#886655,#DD9977,#EECCAA,#EEEEEE,#CC99CC",
                    "#070A1E,#382230,#58423F,#888069,#C1BF95",
                    "#553333,#99aaaa,#998866,#cccc99,#aabbaa",
                    "#223333,#889999,#dd9988,#ddeedd,#bbcccc",
                    "#332244,#bb3355,#998899,#ff5555,#ffdd99",
                    "#FF6600,#F6F6EF,#828282,#000000",
                    "#2B2B2D,#166622,#2FBB4F,#922729",
                    "#332244,#5566aa,#aa7799,#dd9999,#ffdd99",
                    "#334444,#99aa88,#bbbbaa,#ddddcc,#ccccbb",
                    "#444466,#6666aa,#8888aa,#8877dd,#ccbbff",
                    "#4D90FE,#DD4B39,#F1F1F1,#777777",
                    "#555588,#6688DD,#FFEEFF,#DDCCEE,#BBBBDD",
                    "#3366BB,#CCCCCC,#EEEEEE,#DDDDEE,#FFDD11",
                    "#443344,#aa5555,#668899,#dd8855,#cccccc",
                    "#333355,#4455aa,#997777,#5577dd,#dd9977",
                    "#E96F23,#EC8B26,#ECB842,#6796B8,#5C556A"
                    ];

final InputElement slider = querySelector("#slider");
final CanvasRenderingContext2D ctx =
  (querySelector("#canvas") as CanvasElement).context2D;

void main() {
  init();
  
  querySelector("#update").onClick.listen((e) => updateImage());
  querySelector("#save").onClick.listen((e) => saveImage());
  for(var i=0;i<swatchNames.length;i++){
    querySelector("#swatch-${i}").onClick.listen(updateColors);
  }
  for(var i=0;i<presetNames.length;i++){
    querySelector("#preset-${i}").onClick.listen(updatePresets);
  }
  
  window.onKeyUp.listen((KeyboardEvent e) {
      //user pressed a key
      if (e.keyCode == KeyCode.ENTER) {
        updateImage();
      }
    });
}

void init() {
  //setup interface
  querySelector("#colors-dropdown").innerHtml ="";
  for(var i=0;i<swatchNames.length;i++){
    querySelector("#colors-dropdown").innerHtml += "<li><a href=\"\" id=\"swatch-${i}\">"+swatchNames[i]+"</a></li>";
  }
  
  var presetsDropdown = document.getElementById("presets-dropdown");
  querySelector("#presets-dropdown").innerHtml ="";
  for(var i=0;i<presetNames.length;i++){
    querySelector("#presets-dropdown").innerHtml += "<li><a href=\"\" id=\"preset-${i}\">"+presetNames[i]+"</a></li>";
  }
  
  var date = new DateTime.now().year;
  querySelector("#footer").innerHtml = "&copy; ${date} Zauce Technologies";
  
  updateImage();
}

void updateImage() {
    //define image parameters
    var widthInput = document.getElementById("width");
    var heightInput = document.getElementById("height");
    var densityInputX = document.getElementById("densityX");
    var densityInputY = document.getElementById("densityY");
    var distortionSliderInput = document.getElementById("slider");
    var wrapColorsInput = document.getElementById("wrap");
    var colorsInput = document.getElementById("colors").value;

    canvasWidth = int.parse(widthInput.value);
    canvasHeight = int.parse(heightInput.value);

    //contrain values to their max
    if (int.parse(densityInputX.value) > DENSITY_MAX){
        densityInputX.value = DENSITY_MAX;
    }
    if (int.parse(densityInputY.value) > DENSITY_MAX){
        densityInputY.value = DENSITY_MAX;
    }
    if (int.parse(widthInput.value) > SIZE_MAX){
        widthInput.value = SIZE_MAX;
    }
    if (int.parse(heightInput.value) > SIZE_MAX){
        heightInput.value = SIZE_MAX;
    }
    
    shapeCountX = int.parse(densityInputX.value);
    shapeCountY = int.parse(densityInputY.value);

    distortion = int.parse(distortionSliderInput.value)/10;

    wrapColors = wrapColorsInput.checked;

    //parse colors
    colors=new List();
    var colorCount = -1;
    var colorChars = "0123456789abcdefABCDEF";
    for (var i = 0; i<colorsInput.length; i++) {
        //part of the current color
        if(colorChars.indexOf(colorsInput[i])>-1){
            colors[colorCount]+= colorsInput[i];
        }
        //found a new color
        if (colorsInput[i] == "#"){
            colorCount++;
            colors.add("#");
        }
    }
    shapeWidth = (canvasWidth/shapeCountX)+SHIM;
    shapeHeight = (canvasHeight/(shapeCountY-1))+SHIM; //not sure why this works

    //create node matrix
    var i, j, x = 0, y = 0, nodeMatrix = new List();
    for (i = 0; i < shapeCountX+1; i++) {
        var nodeMatrixInner = new List(shapeCountY);
        for (j = 0; j < shapeCountY; j++) {
            if(i<1 || i>=shapeCountX || j<1 || j>=shapeCountY-1){
                nodeMatrixInner[j] = [x*shapeWidth, y*shapeHeight];
            }else{
                var rnd = new Random();
                nodeMatrixInner[j] = [(x+distortion*(.5-rnd.nextDouble()))*shapeWidth, (y+distortion*(.5-rnd.nextDouble()))*shapeHeight];
            }
            y=y+1;
        }
        nodeMatrix.add(nodeMatrixInner);
        x=x+1;
        y=0;
    }
    
    var canvas = (querySelector("#canvas") as CanvasElement);
    //setup the canvas
    canvas.width = canvasWidth;
    canvas.height = canvasHeight;
    
    //draw the image
    drawImage(nodeMatrix);
    
}

void drawImage(matrix) {
  var colorValues = new List();

      // Draw a triangle location for each corner, it will return to the first point
          for (var i = 0; i <= shapeCountX; i++) {
              for (var j = 0; j < shapeCountY; j++) {
                  var shimx =i*SHIM;
                  var shimy =j*SHIM;
                  var rnd = new Random();
                  int c = (rnd.nextDouble()* colors.length).toInt();
                  ctx.fillStyle = colors[c];
                  if (wrapColors==true){
                      //user wants to wrap the colors
                      if(i==shapeCountX){
                          ctx.fillStyle = colorValues[j];
                      }
                  }
                  ctx.beginPath();
                  if(i%2 == 1){
                      if(j%2 == 1) {
                          // Draw up triangle
                      ctx.moveTo(matrix[i-((i<1) ? 0 : 1)][j+((j>=shapeCountY-1) ? 0 : 1)][0]-shimx, matrix[i-((i<1) ? 0 : 1)][j+((j>=shapeCountY-1) ? 0 : 1)][1]-shimy);
                      ctx.lineTo(matrix[i][j][0]-shimx, matrix[i][j][1]-shimy);
                      ctx.lineTo(matrix[i+((i>=shapeCountX) ? 0 : 1)][j+((j>=shapeCountY-1) ? 0 : 1)][0]-shimx, matrix[i+((i>=shapeCountX) ? 0 : 1)][j+((j>=shapeCountY-1) ? 0 : 1)][1]-shimy);
                      } else {
                          // Draw down triangle
                      ctx.moveTo(matrix[i-((i<1) ? 0 : 1)][j][0]-shimx, matrix[i-((i<1) ? 0 : 1)][j][1]-shimy);
                      ctx.lineTo(matrix[i][j+1][0]-shimx, matrix[i][j+1][1]-shimy);
                      ctx.lineTo(matrix[i+((i>=shapeCountX) ? 0 : 1)][j][0]-shimx, matrix[i+((i>=shapeCountX) ? 0 : 1)][j][1]-shimy);
                      }
                      
                  } else {
                      if(j%2 == 1) {
                          // Draw down triangle
                          // ctx.fillStyle = "#aa0000"; //used for testing
                      ctx.moveTo(matrix[i-((i<1) ? 0 : 1)][j][0]-shimx, matrix[i-((i<1) ? 0 : 1)][j][1]-shimy);
                      ctx.lineTo(matrix[i][j+((j>=shapeCountY-1) ? 0 : 1)][0]-shimx, matrix[i][j+((j>=shapeCountY-1) ? 0 : 1)][1]-shimy);
                      ctx.lineTo(matrix[i+((i>=shapeCountX) ? 0 : 1)][j][0]-shimx, matrix[i+((i>=shapeCountX) ? 0 : 1)][j][1]-shimy);
                      } else {
                          // Draw up triangle
                      ctx.moveTo(matrix[i-((i<1) ? 0 : 1)][j+1][0]-shimx, matrix[i-((i<1) ? 0 : 1)][j+1][1]-shimy);
                      ctx.lineTo(matrix[i][j][0]-shimx, matrix[i][j][1]-shimy);
                      ctx.lineTo(matrix[i+((i>=shapeCountX) ? 0 : 1)][j+1][0]-shimx, matrix[i+((i>=shapeCountX) ? 0 : 1)][j+1][1]-shimy);
                      }
                  }
                  ctx.closePath();
                  ctx.fill();

                  //store the wrapping color values
                  if (i<1) {
                      colorValues.add(ctx.fillStyle);
                  }
              }
          }
          print("Updarted");
}

void saveImage() {
    var canvas = document.getElementById("canvas");
    var save = document.getElementById("save");
    save.innerHtml = save.innerHtml+"<img src=\""+canvas.toDataUrl('image/png')+"\" style=\"display:none\">";
    save.href = canvas.toDataUrl('image/png');
}

void updateColors(Event e) {
    Element sender = e.currentTarget;
    e.preventDefault();
    document.getElementById('color-selector').innerHtml = sender.innerHtml+' <span class="caret">';
    document.getElementById("colors").value = swatchValues[searchStringInArray(sender.innerHtml, swatchNames)];
    updateImage();
}

void updatePresets(Event e) {
    Element sender = e.currentTarget;
    e.preventDefault();
    document.getElementById("width").value = presetValues[searchStringInArray(sender.innerHtml, presetNames)][0];
    document.getElementById("height").value = presetValues[searchStringInArray(sender.innerHtml, presetNames)][1];
    document.getElementById("densityX").value = presetValues[searchStringInArray(sender.innerHtml, presetNames)][2];
    document.getElementById("densityY").value = presetValues[searchStringInArray(sender.innerHtml, presetNames)][3];
    document.getElementById("presets").innerHtml = presetNames[searchStringInArray(sender.innerHtml, presetNames)]+ " <span class=\"caret\"></span>";
    updateImage();
}

int searchStringInArray (str, strArray) {
    for (var j=0; j<strArray.length; j++) {
        if (strArray[j] == str) return j;
    }
    return -1;
}
