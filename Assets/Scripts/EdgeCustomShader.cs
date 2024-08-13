using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class EdgeCustomShader : ShaderGUI
{
  
    // Enum to represent the face culling options
    enum CullMode
    {
        Off = 0,
        Back = 1,
        Front = 2
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // Find the _Face property
        MaterialProperty faceProperty = FindProperty("_Face", properties);

        // Convert the current value to the enum
        CullMode cullMode = (CullMode)faceProperty.floatValue;

        // Display a dropdown in the Inspector
        cullMode = (CullMode)EditorGUILayout.EnumPopup("Render Face", cullMode);

        // Update the material property with the selected value
        faceProperty.floatValue = (float)cullMode;

        // Draw the rest of the properties as default
        base.OnGUI(materialEditor, properties);
    }
}
