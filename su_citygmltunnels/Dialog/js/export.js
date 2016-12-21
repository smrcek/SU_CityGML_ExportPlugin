var latitude;
var longitude;

/* ------------------------------------------------------------------------------------ */
/* UTM Converter */
var pi = 3.14159265358979;

/* Ellipsoid model constants (actual values here are for WGS84) */
var sm_a = 6378137.0;
var sm_b = 6356752.314;
var sm_EccSquared = 6.69437999013e-03;

var UTMScaleFactor = 0.9996;

/*
* DegToRad
*
* Converts degrees to radians.
*
*/
function DegToRad (deg)
{
    return (deg / 180.0 * pi)
}

/*
* ArcLengthOfMeridian
*
* Computes the ellipsoidal distance from the equator to a point at a
* given latitude.
*
* Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
* GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
*
* Inputs:
*     phi - Latitude of the point, in radians.
*
* Globals:
*     sm_a - Ellipsoid model major axis.
*     sm_b - Ellipsoid model minor axis.
*
* Returns:
*     The ellipsoidal distance of the point from the equator, in meters.
*
*/
function ArcLengthOfMeridian (phi)
{
    var alpha, beta, gamma, delta, epsilon, n;
    var result;

    /* Precalculate n */
    n = (sm_a - sm_b) / (sm_a + sm_b);

    /* Precalculate alpha */
    alpha = ((sm_a + sm_b) / 2.0)
    * (1.0 + (Math.pow (n, 2.0) / 4.0) + (Math.pow (n, 4.0) / 64.0));

    /* Precalculate beta */
    beta = (-3.0 * n / 2.0) + (9.0 * Math.pow (n, 3.0) / 16.0)
    + (-3.0 * Math.pow (n, 5.0) / 32.0);

    /* Precalculate gamma */
    gamma = (15.0 * Math.pow (n, 2.0) / 16.0)
    + (-15.0 * Math.pow (n, 4.0) / 32.0);

    /* Precalculate delta */
    delta = (-35.0 * Math.pow (n, 3.0) / 48.0)
    + (105.0 * Math.pow (n, 5.0) / 256.0);

    /* Precalculate epsilon */
    epsilon = (315.0 * Math.pow (n, 4.0) / 512.0);

    /* Now calculate the sum of the series and return */
    result = alpha
    * (phi + (beta * Math.sin (2.0 * phi))
        + (gamma * Math.sin (4.0 * phi))
        + (delta * Math.sin (6.0 * phi))
        + (epsilon * Math.sin (8.0 * phi)));

    return result;
}

/*
* UTMCentralMeridian
*
* Determines the central meridian for the given UTM zone.
*
* Inputs:
*     zone - An integer value designating the UTM zone, range [1,60].
*
* Returns:
*   The central meridian for the given UTM zone, in radians, or zero
*   if the UTM zone parameter is outside the range [1,60].
*   Range of the central meridian is the radian equivalent of [-177,+177].
*
*/
function UTMCentralMeridian (zone)
{
    var cmeridian;

    cmeridian = DegToRad (-183.0 + (zone * 6.0));

    return cmeridian;
}

/*
* MapLatLonToXY
*
* Converts a latitude/longitude pair to x and y coordinates in the
* Transverse Mercator projection.  Note that Transverse Mercator is not
* the same as UTM; a scale factor is required to convert between them.
*
* Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J.,
* GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
*
* Inputs:
*    phi - Latitude of the point, in radians.
*    lambda - Longitude of the point, in radians.
*    lambda0 - Longitude of the central meridian to be used, in radians.
*
* Outputs:
*    xy - A 2-element array containing the x and y coordinates
*         of the computed point.
*
* Returns:
*    The function does not return a value.
*
*/
function MapLatLonToXY (phi, lambda, lambda0, xy)
{
    var N, nu2, ep2, t, t2, l;
    var l3coef, l4coef, l5coef, l6coef, l7coef, l8coef;
    var tmp;

    /* Precalculate ep2 */
    ep2 = (Math.pow (sm_a, 2.0) - Math.pow (sm_b, 2.0)) / Math.pow (sm_b, 2.0);

    /* Precalculate nu2 */
    nu2 = ep2 * Math.pow (Math.cos (phi), 2.0);

    /* Precalculate N */
    N = Math.pow (sm_a, 2.0) / (sm_b * Math.sqrt (1 + nu2));

    /* Precalculate t */
    t = Math.tan (phi);
    t2 = t * t;
    tmp = (t2 * t2 * t2) - Math.pow (t, 6.0);

    /* Precalculate l */
    l = lambda - lambda0;

    /* Precalculate coefficients for l**n in the equations below
   so a normal human being can read the expressions for easting
   and northing
   -- l**1 and l**2 have coefficients of 1.0 */
    l3coef = 1.0 - t2 + nu2;

    l4coef = 5.0 - t2 + 9 * nu2 + 4.0 * (nu2 * nu2);

    l5coef = 5.0 - 18.0 * t2 + (t2 * t2) + 14.0 * nu2
    - 58.0 * t2 * nu2;

    l6coef = 61.0 - 58.0 * t2 + (t2 * t2) + 270.0 * nu2
    - 330.0 * t2 * nu2;

    l7coef = 61.0 - 479.0 * t2 + 179.0 * (t2 * t2) - (t2 * t2 * t2);

    l8coef = 1385.0 - 3111.0 * t2 + 543.0 * (t2 * t2) - (t2 * t2 * t2);

    /* Calculate easting (x) */
    xy[0] = N * Math.cos (phi) * l
    + (N / 6.0 * Math.pow (Math.cos (phi), 3.0) * l3coef * Math.pow (l, 3.0))
    + (N / 120.0 * Math.pow (Math.cos (phi), 5.0) * l5coef * Math.pow (l, 5.0))
    + (N / 5040.0 * Math.pow (Math.cos (phi), 7.0) * l7coef * Math.pow (l, 7.0));

    /* Calculate northing (y) */
    xy[1] = ArcLengthOfMeridian (phi)
    + (t / 2.0 * N * Math.pow (Math.cos (phi), 2.0) * Math.pow (l, 2.0))
    + (t / 24.0 * N * Math.pow (Math.cos (phi), 4.0) * l4coef * Math.pow (l, 4.0))
    + (t / 720.0 * N * Math.pow (Math.cos (phi), 6.0) * l6coef * Math.pow (l, 6.0))
    + (t / 40320.0 * N * Math.pow (Math.cos (phi), 8.0) * l8coef * Math.pow (l, 8.0));

    return;
}

/*
* LatLonToUTMXY
*
* Converts a latitude/longitude pair to x and y coordinates in the
* Universal Transverse Mercator projection.
*
* Inputs:
*   lat - Latitude of the point, in radians.
*   lon - Longitude of the point, in radians.
*   zone - UTM zone to be used for calculating values for x and y.
*          If zone is less than 1 or greater than 60, the routine
*          will determine the appropriate zone from the value of lon.
*
* Outputs:
*   xy - A 2-element array where the UTM x and y values will be stored.
*
* Returns:
*   The UTM zone used for calculating the values of x and y.
*
*/
function LatLonToUTMXY (lat, lon, zone, xy)
{
    MapLatLonToXY (lat, lon, UTMCentralMeridian (zone), xy);

    /* Adjust easting and northing for UTM system. */
    xy[0] = xy[0] * UTMScaleFactor + 500000.0;
    xy[1] = xy[1] * UTMScaleFactor;
    if (xy[1] < 0.0)
        xy[1] = xy[1] + 10000000.0;

    return zone;
}

/* ------------------------------------------------------------------------------------ */

function LatLonToGK(lat,lon,zone,xy) {
    var rho=180/Math.PI;
    var rm,e2,c,bf,g,co,g2,g1,t,dl,fa;
    e2=0.0067192188;
    c=6398786.849;
    bf=lat/rho;
    g=111120.61962*lat-15988.63853*Math.sin(2*bf)+
    16.72995*Math.sin(4*bf)-0.02178*Math.sin(6*bf)+
    0.00003*Math.sin(8*bf);
    co=Math.cos(bf);
    g2=e2*(co*co);
    g1=c/Math.sqrt(1+g2);
    t=Math.tan(bf);
    dl=lon-zone*3;
    fa=co*dl/rho;
    y=g+fa*fa*t*g1/2+fa*fa*fa*fa*t*g1*(5-t*t+9*g2)/24;
    rm=fa*g1+fa*fa*fa*g1*(1-t*t+g2)/6+
    fa*fa*fa*fa*fa*g1*(5-18*t*t*t*t*t*t)/120;
    x=rm+zone*1000000+500000;
    xy[0]=x;
    xy[1]=y;
    return;
}

/* ------------------------------------------------------------------------------------ */
function move_to_center()
{
    window.location = "skp:move@" + screen.width + "," + screen.height + ":" + document.body.offsetWidth + "," + document.body.offsetHeight;
}

function swapContent(num)
{
    for(i=0; obj = document.getElementById("content"+ i); ++i)
    {
        obj.style.display = "none";
    }
    document.getElementById("content"+ num).style.display = "block";

    for(i=0; obj = document.getElementById("tab"+ i); ++i)
    {
        obj.className = "unselected";
    }
    document.getElementById("tab"+ num).className = "selected";

    return false;
}
function Layervisible(layername)
{
    window.location = "skp:Layervisible@" + layername + ";" + document.getElementById(layername).checked;
}
function get_Geolocation()
{
    window.location = "skp:get_Geolocation";
}
function convert_GK()
{
    get_Geolocation();

    var xy = new Array(2);

    if ((longitude < -180.0) || (180.0 <= longitude)) {
        alert ("The longitude you entered is out of range.  " +
            "Please enter a number in the range [-180, 180).");
        return false;
    }

    if ((latitude < -90.0) || (90.0 < latitude)) {
        alert ("The latitude you entered is out of range.  " +
            "Please enter a number in the range [-90, 90].");
        return false;
    }

    zone = 2 * Math.floor(longitude/6) + 1;
    LatLonToGK(latitude,longitude,zone,xy);

    document.Daten.offset_x.value = xy[0];
    document.Daten.offset_y.value = xy[1];
}
function convert_UTM()
{
    get_Geolocation();

    var xy = new Array(2);

    if ((longitude < -180.0) || (180.0 <= longitude)) {
        alert ("The longitude you entered is out of range.  " +
            "Please enter a number in the range [-180, 180).");
        return false;
    }

    if ((latitude < -90.0) || (90.0 < latitude)) {
        alert ("The latitude you entered is out of range.  " +
            "Please enter a number in the range [-90, 90].");
        return false;
    }

    // Compute the UTM zone.
    zone = Math.floor ((longitude + 180.0) / 6) + 1;

    zone = LatLonToUTMXY (DegToRad (latitude), DegToRad (longitude), zone, xy);

    document.Daten.offset_x.value = xy[0];
    document.Daten.offset_y.value = xy[1];

/* Set the output controls.  */
/*
  document.frmConverter.txtX.value = xy[0];
  document.frmConverter.txtY.value = xy[1];
  document.frmConverter.txtZone.value = zone;
  if (latitude < 0)
      // Set the S button.
      document.frmConverter.rbtnHemisphere[1].checked = true;
  else
      // Set the N button.
      document.frmConverter.rbtnHemisphere[0].checked = true;
*/
}
function loadworldfile()
{
    window.location = "skp:loadworldfile";
}
function saveOffset()
{
    window.location = "skp:saveOffset";
}
function GmlExport()
{
    boxen = document.getElementsByName("layer");
    parameter = ""
    for(i = 0; i < boxen.length; i++)
    {
        if(boxen[i].checked)
            parameter += boxen[i].id + "|"

    }
    parameter += ";";

    boxen = document.getElementsByName("LOD");

    parameter += $('#LOD').val() + ";"

    if(obj = document.getElementById("texture"))
        parameter += obj.value + ";"
    else
        parameter += ";";

    boxen = document.getElementsByName("appearance");
    for(i = 0; i < boxen.length; i++)
    {
        if(boxen[i].checked)
            parameter += ++i + ";"
    }

    boxen = document.getElementsByName("mat");
    for(i = 0; i < boxen.length; i++)
    {
        if(boxen[i].checked)
            parameter += ++i + ";"
    }

    boxen = document.getElementsByName("ids");
    for(i = 0; i < boxen.length; i++)
    {
        if(boxen[i].checked)
            parameter += ++i + ";"
    }

    layer = document.getElementById("groupsurfacetype");
    if(layer.checked)
        parameter += "1;"
    else
        parameter += "0;";

    layer = document.getElementById("collision_correct_id");
    if(layer.checked)
        parameter += "1;"
    else
        parameter += "0;";

    orientation = document.getElementsByName("orientation");
    coord = -1;
    for( var i=0; i<orientation.length; i++)
    {
        if(orientation[i].checked)
        {
            coord = ++i;
            break;
        }
    }
    parameter += coord + ";";

    if(obj = document.getElementById("coordinate_system"))
        parameter += obj.value + ";";
    else
        parameter += ";";

    parameter += $('#GmlType').val() + ";"
        
    window.location = "skp:GmlExport@" + parameter;
}

$(document).ready(function() {
    move_to_center();
    window.location = 'skp:IsBatch';
    window.location = 'skp:LoadOffset';
});

function OnIsBatch(batchMode)
{
    var textureDiv = '<input id="texture" name="texture" type="text" class="txtField" size="40" maxlength="100" ';
    var offsetDiv = '';

    if(batchMode)
    {
        textureDiv += 'value="textures for < Filebasename >" disabled>';
        var layerDiv = '<input name="layer" type="checkbox" checked disabled id="allLayer"> All layers';
        $('#layerDiv').html(layerDiv);
    }
    else
    {
        textureDiv += 'value="textures">';
        window.location = "skp:GetLayer";
        offsetDiv += '<a href="#" class="btnSafeOffset ui-state-default ui-corner-all button button-left">Safe Offset</a><br>'; //'<input type="button" name="saveOffset_Button" value="Safe Offset" style="margin-left:125px" onclick="saveOffset()"><br>';
        offsetDiv += '<label for="offset_x" style="clear: left;">X</label><input id="offset_x" name="offset_x" class="txtField" type="text" size="30" maxlength="30" value="0"><br><br>';
        offsetDiv += '<label for="offset_y">Y</label><input id="offset_y" name="offset_y" class="txtField" type="text" size="30" maxlength="30" value="0"><br><br>';
        offsetDiv += '<label for="offset_z">Z</label><input id="offset_z" name="offset_z" class="txtField" type="text" size="30" maxlength="30" value="0"><br><br>';
        offsetDiv += '<label for="yaw">Yaw</label><input id="yaw" name="yaw" class="txtField" type="text" size="30" maxlength="30" value="0"><br><br>';
        offsetDiv += '<a href="#" class="btnConvertGK ui-state-default ui-corner-all button button-left">Lat/Lon->GK</a>'; //'<input type="button" name="convert_GK_Button" value="Lat/Lon->GK" onclick="convert_GK()">';
        offsetDiv += '<a href="#" class="btnConvertUTM ui-state-default ui-corner-all button button-left">Lat/Lon->UTM</a>'; //'<input type="button" name="convert_UTM_Button" value="Lat/Lon->UTM" onclick="convert_UTM()">';
        offsetDiv += '<a href="#" class="btnLoadWorldfile ui-state-default ui-corner-all button button-left">Load Worldfile</a>'; //'<input type="button" name="loadworldfilebutton" value="Load Worldfile" onclick="loadworldfile()">';
    }

    $('#textureDiv').html(textureDiv);
    $('#offsetDiv').html(offsetDiv);
}

function OnGetLayer(str)
{
    var layerDiv = "";
    var layer = $.parseJSON(str);
    $.each(layer,function(k,v) {
        layerDiv += '<input name="layer" type="checkbox" ';
        if(v > 0)
        {
            layerDiv += 'checked ';
            if(v == 2)
                layerDiv += 'disabled ';
        }
        layerDiv += 'id="' + k + '" onclick="Layervisible(\'' + k + '\')">' + k;
        if(v == 2)
            layerDiv += ' (active)';
        layerDiv += '<br><br>';
    });

    $('#layerDiv').html(layerDiv);
}

$(function(){
    // Tabs
    $('#tabs').tabs({
        selected: null
    });
    $('#tabs').tabs().tabs('select', 0);

    // Button
    $('.btnAccept').click(function(){
        GmlExport();
    });

    $('.btnCancel').click(function(){
        window.location = "skp:Abort";
    });

    $('.btnSafeOffset').click(function(){
        saveOffset();
    });

    $('.btnConvertGK').click(function(){
        convert_GK();
    });

    $('.btnConvertUTM').click(function(){
        convert_UTM();
    });

    $('.btnLoadWorldfile').click(function(){
        loadworldfile();
    });
});