var $availableStdAttributes = null;
var $attributes = {std:{},gen:{}};

function ActionContent(type, key)
{
    var action = '<ul class="icons ui-widget ui-helper-clearfix"><li class="ui-state-default ui-corner-all" onclick="EditAttribute(';
    action += type + ",'" + key + "'";
    action += ')"><span class="ui-icon ui-icon-tag"></span></li><li class="ui-state-default ui-corner-all" onclick="RemoveAttribute(';
    action += type + ",'" + key + "'";
    action += ')"><span class="ui-icon ui-icon-trash"></span></li></ul>';
    return action;
}

function LoadContent(tabindex){
    var content = '<table class="ui-widget ui-widget-content"><tr class="ui-widget-header"><th>Key</th><th>Value</th><th class="action">Action</th></tr>';
    if(tabindex == 0)
    {
        $.each($attributes['std'], function(key, value) {
            content += '<tr><td>' + key + '</td><td>' + value + '</td><td class="action">' + ActionContent(0,key) + '</td></tr>';
        });
        content += '</table>';
        $('#tabs-1-content').html(content);
    }
    else if(tabindex == 1)
    {
        $.each($attributes['gen'], function(key, value) {
            content += '<tr><td>' + key + '</td><td>' + value + '</td><td class="action">' + ActionContent(1,key) + '</td></tr>';
        });
        content += '</table>';
        $('#tabs-2-content').html(content);
    }
}

$(document).ready(function() {
      ImportStandardAttributes();
      ImportGenericAttributes();
      LoadAvailableStdAttributes();
});

function LoadAvailableStdAttributes()
{
    window.location='skp:LoadAvailableStdAttributes';
}

function OnLoadAvailableStdAttributes(str)
{
    $availableStdAttributes = str.split('|');
    SetAvailableStdAttributes();
}

function SetAvailableStdAttributes()
{
    var options = '';
    $.each($availableStdAttributes, function(key, value) {
        if($attributes['std'][value] == null)
            options += '<option>' + value + '</option>';
    });
    $('#stdName').html(options);
    $('#stdName').selectmenu({'refresh': true});
}

function ImportStandardAttributes()
{
    window.location='skp:ImportStandardAttributes';
}

function OnImportStandardAttributes(str)
{
    var attribs = $.parseJSON(str);
    $.each(attribs,function(k,v) {
       $attributes['std'][k] = v;
    });
}

function ImportGenericAttributes()
{
    window.location='skp:ImportGenericAttributes';
}

function OnImportGenericAttributes(str)
{
    var attribs = $.parseJSON(str);
    $.each(attribs,function(k,v) {
       $attributes['gen'][k] = v;
    });
}

function EditAttribute(type, key)
{
    $('#editType').val(type);
    $('#editName').val(key);
    if(type == 0)
    {
        $('#editValue').val($attributes['std'][key]);
        $('#editDialog').dialog('open');
    }
    else if(type == 1)
    {
        $('#editValue').val($attributes['gen'][key]);
        $('#editDialog').dialog('open');
    }
}

function RemoveAttribute(type, key)
{
    if(type == 0)
    {
        if($attributes['std'][key] != null)
        {
            window.location='skp:RemoveAttribute@std##||##' + key;
            delete $attributes['std'][key];
            SetAvailableStdAttributes();
            LoadContent(0);
        }
    }
    else if(type == 1)
    {
        if($attributes['gen'][key] != null)
        {
            window.location='skp:RemoveAttribute@gen##||##' + key;
            delete $attributes['gen'][key];
            LoadContent(1);
        }
    }
}

$(function(){
    // Tabs
    $('#tabs').tabs({
        selected: null,
        select: function(event,ui){
            LoadContent(ui.index);
        }
    });
    $('#tabs').tabs().tabs('select', 0);

    // Dialog
    $('#stdDialog').dialog({
        autoOpen: false,
        resizable: false,
        width: 400,
        buttons: {
            "Add": function() {
                if($attributes['std'][$('#stdName').val()] != null)
                    alert('Attribute name already exists!');
                else
                {
                    window.location='skp:AddAttribute@std##||##' + $('#stdName').val() + '##||##' + $('#stdValue').val();
                    $attributes['std'][$('#stdName').val()] = $('#stdValue').val();
                    LoadContent(0);
                    $('#stdValue').val('');
                    $(this).dialog("close");
                    SetAvailableStdAttributes();
                }
            },
            "Cancel": function() {
                $('#stdValue').val('');
                $(this).dialog("close");
            }
        }
    });

    $('#genDialog').dialog({
        autoOpen: false,
        resizable: false,
        width: 400,
        buttons: {
            "Add": function() {
                if($attributes['gen'][$('#genName').val()] != null)
                    $('#attributeExistsDialog').dialog('open');
                else
                {
                    window.location='skp:AddAttribute@gen##||##' + $('#genName').val() + '##||##' + $('#genValue').val();
                    $attributes['gen'][$('#genName').val()] = $('#genValue').val();
                    LoadContent(1);
                    $('#genName').val('');
                    $('#genValue').val('');
                    $(this).dialog("close");
                }
            },
            "Cancel": function() {
                $('#genName').val('');
                $('#genValue').val('');
                $(this).dialog("close");
            }
        }
    });

    $('#editDialog').dialog({
        autoOpen: false,
        resizable: false,
        width: 400,
        buttons: {
            "Save": function() {
                if($('#editType').val() == '0')
                {
                    window.location='skp:RemoveAttribute@std##||##' + $('#editName').val();
                    window.location='skp:AddAttribute@std##||##' + $('#editName').val() + '##||##' + $('#editValue').val();
                    $attributes['std'][$('#editName').val()] = $('#editValue').val();
                    LoadContent(0);
                }
                else if($('#editType').val() == '1')
                {
                    window.location='skp:RemoveAttribute@gen##||##' + $('#editName').val();
                    window.location='skp:AddAttribute@gen##||##' + $('#editName').val() + '##||##' + $('#editValue').val();
                    $attributes['gen'][$('#editName').val()] = $('#editValue').val();
                    LoadContent(1);
                }

                $('#editType').val('');
                $('#editName').val('');
                $('#editValue').val('');
                $(this).dialog("close");
            },
            "Cancel": function() {
                $('#editType').val('');
                $('#editName').val('');
                $('#editValue').val('');
                $(this).dialog("close");
            }
        }
    });

    $('#attributeExistsDialog').dialog({
        modal: true,
        autoOpen: false,
        resizable: false,
        width: 200,
        heigth: 30,
        buttons: {
            Ok: function() {
                $(this).dialog('close');
            }
        }
    });

    // Dialog Link
    $('#stdDialogLink').click(function(){
        if($('#stdName').html() != '')
            $('#stdDialog').dialog('open');
        return false;
    });

    $('#genDialogLink').click(function(){
        $('#genDialog').dialog('open');
        return false;
    });

    $('select#stdName').selectmenu({
        style:'dropdown',
        maxHeight: 200
    });

    // Button
    $('.btnAccept').click(function(){
        window.location='skp:Accept';
    });

    $('.btnCancel').click(function(){
        window.location='skp:Cancel';
    });

    //var recursiveEncoded = $.toJSON(myObject);
});