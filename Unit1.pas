unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Types3D,
  System.Math.Vectors, FMX.Controls3D, Gorilla.Light, Gorilla.Viewport,
  Gorilla.Control, Gorilla.Transform, Gorilla.Mesh, Gorilla.Model, Gorilla.Cube,
  Gorilla.SkyBox, Gorilla.Controller, Gorilla.Controller.Passes.Environment,
  FMX.Objects3D, Gorilla.Physics, FMX.MaterialSources, Gorilla.Material.Default,
  Gorilla.Material.Blinn, Gorilla.Sphere, FMX.Controls.Presentation,
  FMX.StdCtrls, Gorilla.Plane, Gorilla.Camera, Gorilla.Physics.Q3.Renderer,
  Gorilla.Material.Lambert, Gorilla.Physics.Q3.Body, Gorilla.Physics.Q3.Contact,
  FMX.Objects, Gorilla.Audio.FMOD, Gorilla.Audio.FMOD.Intf.Channel,
  Gorilla.Audio.FMOD.Intf.Sound;

const
  /// <summary>
  /// Set this constant to TRUE, to see physics colliders. Iteresting for debugging.
  /// </summary>
  SHOW_PHYSICS_COLLIDERS = false;
  /// <summary>
  /// The general white ball origin position to be resetted, when it falls off
  /// the table or into a hole.
  /// </summary>
  WHITEBALL_ORIGIN : TPoint3D = (X: 0; Y: -5; Z: -10;);

type
  TForm1 = class(TForm)
    GorillaViewport1: TGorillaViewport;
    GorillaLight1: TGorillaLight;
    BilliardTable: TGorillaModel;
    GorillaSkyBox1: TGorillaSkyBox;
    GorillaPhysicsSystem1: TGorillaPhysicsSystem;
    Ball8: TGorillaSphere;
    Ball8Material: TGorillaBlinnMaterialSource;
    WhiteBall: TGorillaSphere;
    WhiteBallMaterial: TGorillaBlinnMaterialSource;
    Ball1: TGorillaSphere;
    Ball1Material: TGorillaBlinnMaterialSource;
    Ball2: TGorillaSphere;
    Ball2Material: TGorillaBlinnMaterialSource;
    Ball3: TGorillaSphere;
    Ball4: TGorillaSphere;
    Ball5: TGorillaSphere;
    Ball6: TGorillaSphere;
    Ball7: TGorillaSphere;
    Ball9: TGorillaSphere;
    Ball10: TGorillaSphere;
    Ball11: TGorillaSphere;
    Ball12: TGorillaSphere;
    Ball13: TGorillaSphere;
    Ball14: TGorillaSphere;
    Ball15: TGorillaSphere;
    Ball10Material: TGorillaBlinnMaterialSource;
    Ball11Material: TGorillaBlinnMaterialSource;
    Ball12Material: TGorillaBlinnMaterialSource;
    Ball13Material: TGorillaBlinnMaterialSource;
    Ball14Material: TGorillaBlinnMaterialSource;
    Ball15Material: TGorillaBlinnMaterialSource;
    Ball3Material: TGorillaBlinnMaterialSource;
    Ball4Material: TGorillaBlinnMaterialSource;
    Ball5Material: TGorillaBlinnMaterialSource;
    Ball6Material: TGorillaBlinnMaterialSource;
    Ball7Material: TGorillaBlinnMaterialSource;
    Ball9Material: TGorillaBlinnMaterialSource;
    Timer1: TTimer;
    Dummy1: TDummy;
    CameraTarget: TDummy;
    GorillaCamera1: TGorillaCamera;
    DirArrow: TRectangle3D;
    GorillaLambertMaterialSource1: TGorillaLambertMaterialSource;
    ArrowOrient: TDummy;
    Floor: TGorillaCube;
    FloorMaterial: TGorillaBlinnMaterialSource;
    Holes: TDummy;
    Hole1: TDummy;
    Hole2: TDummy;
    Hole3: TDummy;
    Hole4: TDummy;
    Hole5: TDummy;
    Hole6: TDummy;
    BallImages: TRectangle;
    Ball1Image: TImage;
    Ball2Image: TImage;
    Ball14Image: TImage;
    Ball13Image: TImage;
    Ball12Image: TImage;
    Ball11Image: TImage;
    Ball10Image: TImage;
    Ball9Image: TImage;
    Ball8Image: TImage;
    Ball7Image: TImage;
    Ball6Image: TImage;
    Ball5Image: TImage;
    Ball4Image: TImage;
    Ball3Image: TImage;
    Ball15Image: TImage;
    GorillaFMODAudioManager1: TGorillaFMODAudioManager;
    StateWait: TImage;
    StateField: TRectangle;
    StateActive: TImage;
    PowerPlane: TGorillaPlane;
    procedure Timer1Timer(Sender: TObject);
    procedure Dummy1Render(Sender: TObject; Context: TContext3D);
    procedure GorillaViewport1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure GorillaViewport1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GorillaViewport1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GorillaViewport1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure GorillaPhysicsSystem1BeginContact(
      const AContact: PQ3ContactConstraint; const ABodyA, ABodyB: TQ3Body);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  protected
    FLastPos     : TPointF;
    FToggleCheck : UInt64;
    FIsMouseDown : Boolean;
    FMouseShift  : TShiftState;
    FHoles       : Array[0..5] of TDummy;
    FBalls       : Array[0..15] of TGorillaSphere;
    FBallImages  : Array[0..14] of TImage;
    FBallOrigins : Array[0..15] of TPoint3D;

    FMusic       : IGorillaFMODSound;
    FClackSound  : IGorillaFMODSound;
    FChannels    : Array[0..15] of IGorillaFMODChannel;

    /// <summary>
    /// Check if a 3D object is hole dummy. This method is used for hole collision
    /// detection.
    /// </summary>
    function IsHole(AObj : TObject) : Boolean;
    /// <summary>
    /// Check if a 3D object is ball. This method is used for general collision
    /// detection.
    /// </summary>
    function IsBall(AObj : TObject) : Boolean;
    /// <summary>
    /// Plays the ball clack sound depending on the intensity of the impulse.
    /// The higher the impulse, the louder the sound. It ensures that a sound
    /// for a ball is only played once to prevent from a too-robotic sound.
    /// </summary>
    procedure PlayBallSound(ATagIndex : Integer; AImpulse : Single);
    /// <summary>
    /// Removes the collider from physics system, re-positions the ball and
    /// adds a spherical collider again for the object.
    /// </summary>
    procedure ResetBallOrigin(ABall : TGorillaSphere; APosition : TPoint3D);

    /// <summary>
    /// Check if all balls are sleeping. This can only enable to shoot.
    /// </summary>
    function BallsAvailable() : Boolean;

    procedure ActivateState();
    procedure DeactivateState();

    /// <summary>
    /// This enables shooting mode and hides/shows the aiming arrow.
    /// </summary>
    procedure ToggleAvailability();

  public
    /// <summary>
    /// If a ball collides with a hole dummy, it fell into the hole and needs
    /// to be taken off the game. This method sets the opacity to 1.0 for the
    /// specific ball image.
    /// </summary>
    procedure LockBallImage(AIndex : Integer);
    /// <summary>
    /// Sets all ball images on the left side to an opacity of 0.25 to mark them
    /// as still-in-game.
    /// </summary>
    procedure UnlockBallImages();
    /// <summary>
    /// Loads the music and sound effects from file. It automatically plays the
    /// music in loop.
    /// </summary>
    procedure LoadAudio();
    /// <summary>
    /// This method is called when the application closes. All sounds and channels
    /// will be stopped and interfaces getting freed.
    /// </summary>
    procedure UnloadAudio();
  end;

  /// <summary>
  /// Computes a normal vector from a eulerian degree value of the y-axis. This
  /// function is used by adjustment of the power arrow for shooting.
  /// </summary>
  function GetNormalVector(AAngleY: Double): TPoint3D;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.Math,
  System.IOUtils,
  Gorilla.Utils.Math,
  Gorilla.Audio.FMOD.Lib.Common;

function GetNormalVector(AAngleY: Double): TPoint3D;
var
  LRotationMatrix: TMatrix3D;
  LRotatedVector : TVector3D;
begin
  // Start with a vector pointing in the positive z-direction
  LRotatedVector := TVector3D(TPoint3D.Create(0, 0, 1));

  // Create the rotation matrix for y-axis rotation by yRotationAngle
  LRotationMatrix := TMatrix3D.CreateRotationY(DegToRad(AAngleY));

  // Apply the rotation to the vector
  LRotatedVector := LRotatedVector * LRotationMatrix;

  // Project the rotated vector onto the xz-plane
  LRotatedVector.Y := 0;

  // Normalize the resulting vector
  Result := TPoint3D(LRotatedVector).Normalize();
end;

{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
var I : Integer;
begin
  // Let's enable realtime global illumination (only on modern machines - otherwise
  // a very low FPS may occur)
  GorillaViewport1.GlobalIllumDetail := 4;
  GorillaViewport1.GlobalIllumSoftness := 2;
  GorillaViewport1.ShadowStrength := 2;

  // Prepare list of hole dummies
  FHoles[0] := Hole1;
  FHoles[1] := Hole2;
  FHoles[2] := Hole3;
  FHoles[3] := Hole4;
  FHoles[4] := Hole5;
  FHoles[5] := Hole6;

  // Prepare list of balls
  FBalls[ 0] := Ball1;
  FBalls[ 1] := Ball2;
  FBalls[ 2] := Ball3;
  FBalls[ 3] := Ball4;
  FBalls[ 4] := Ball5;
  FBalls[ 5] := Ball6;
  FBalls[ 6] := Ball7;
  FBalls[ 7] := Ball8;
  FBalls[ 8] := Ball9;
  FBalls[ 9] := Ball10;
  FBalls[10] := Ball11;
  FBalls[11] := Ball12;
  FBalls[12] := Ball13;
  FBalls[13] := Ball14;
  FBalls[14] := Ball15;
  FBalls[15] := WhiteBall;

  // Since we design the game at designtime - we set the origin positions
  // dynamically here
  for I := Low(FBalls) to High(FBalls) do
  begin
    FBallOrigins[I] := FBalls[I].Position.Point;
    FBallOrigins[I].Y := FBallOrigins[I].Y - 2;
  end;

  FBallImages[ 0] := Ball1Image;
  FBallImages[ 1] := Ball2Image;
  FBallImages[ 2] := Ball3Image;
  FBallImages[ 3] := Ball4Image;
  FBallImages[ 4] := Ball5Image;
  FBallImages[ 5] := Ball6Image;
  FBallImages[ 6] := Ball7Image;
  FBallImages[ 7] := Ball8Image;
  FBallImages[ 8] := Ball9Image;
  FBallImages[ 9] := Ball10Image;
  FBallImages[10] := Ball11Image;
  FBallImages[11] := Ball12Image;
  FBallImages[12] := Ball13Image;
  FBallImages[13] := Ball14Image;
  FBallImages[14] := Ball15Image;

  UnlockBallImages();

  // Load all sounds, channels and music
  LoadAudio();

  // By default we deactivate the shooting mode, because balls falling down a bit
  // at the beginning until they're going into sleeping-state
  PowerPlane.SetOpacityValue(0.5);
  DeactivateState();

  // Activate physics
  GorillaPhysicsSystem1.Active := true;

  // Activate timer: for camera adjustment and auto-toggle mode
  Timer1.Enabled := true;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UnloadAudio();
end;

procedure TForm1.Dummy1Render(Sender: TObject; Context: TContext3D);
var LRender : TQ3Render;
begin
  // Check if we want to see physics colliders
  if not SHOW_PHYSICS_COLLIDERS then
    Exit;

  // Here we render physics colliders for debugging
  LRender.Context := Context;
  GorillaPhysicsSystem1.Engine.Render(@LRender);
end;

procedure TForm1.UnloadAudio();
var I : Integer;
begin
  // Stop all playbacks and unref all interfaces on shutdown
  GorillaFMODAudioManager1.StopAllChannels();
  for I := Low(FChannels) to High(FChannels) do
    FChannels[I] := nil;

  FClackSound := nil;
  FMusic := nil;
end;

procedure TForm1.LoadAudio();
var LPath : String;
begin
  // Get the path to the audio assets folder
{$IFDEF MSWINDOWS}
  LPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    IncludeTrailingPathDelimiter('assets') +
    IncludeTrailingPathDelimiter('audio');
{$ELSE}
  LPath := IncludeTrailingPathDelimiter(TPath.GetHomePath()) +
    IncludeTrailingPathDelimiter('assets') +
    IncludeTrailingPathDelimiter('audio');
{$ENDIF}

  // Load the music file
  FMusic := GorillaFMODAudioManager1.LoadSoundFromFile(LPath +
    'cool-jazz-loops-2641.mp3');
  // Set it to be looped
  FMusic.Mode  := FMOD_LOOP_NORMAL;
  // Automatically start playing
  GorillaFMODAudioManager1.PlaySound(FMusic);

  // Prepare and load the clack sound of the balls - it's not getting played
  // already
  FClackSound := GorillaFMODAudioManager1.LoadSoundFromFile(LPath +
    '539854__za-games__billiard-ball-clack.wav');
end;

procedure TForm1.LockBallImage(AIndex : Integer);
begin
  if (AIndex > -1) and (AIndex < System.Length(FBallImages)) then
    FBallImages[AIndex].Opacity := 1;
end;

procedure TForm1.UnlockBallImages();
var I : Integer;
begin
  for I := Low(FBallImages) to High(FBallImages) do
  begin
    FBallImages[I].Opacity := 0.25;
  end;
end;

function TForm1.IsHole(AObj : TObject) : Boolean;
var I : Integer;
begin
  for I := Low(FHoles) to High(FHoles) do
  begin
    if FHoles[I] = AObj then
    begin
      Result := true;
      Exit;
    end;
  end;

  Result := false;
end;

function TForm1.IsBall(AObj : TObject) : Boolean;
var I : Integer;
begin
  for I := Low(FBalls) to High(FBalls) do
  begin
    if FBalls[I] = AObj then
    begin
      Result := true;
      Exit;
    end;
  end;

  Result := false;
end;

procedure TForm1.PlayBallSound(ATagIndex : Integer; AImpulse : Single);
var LTagIdx : Integer;
    LImpulse : Single;
begin
  // Only play the sound, when a valid index was supplied
  LTagIdx := ATagIndex;
  if not ( (LTagIdx > -1) and ((LTagIdx < 16) or (LTagIdx > 15)) ) then
    Exit;

  // Compute the impulse value and limit it between 0.0 - 1.0
  LImpulse := Min(1, Max(0, AImpulse / 8));

  // We're calling this method from another thread, so we have to synchronize
  // with the main thread!
  TThread.Queue(nil,
    procedure()
    begin
      // Get the sound channel for the specific ball - we don't wan robot sound
      // due to multiple playback, so we only play the "clack" once per ball
      if (LTagIdx > 14) then
      begin
        // white ball playback with the fixed index
        if Assigned(FChannels[15]) then
        begin
          if not FChannels[15].IsPlaying then
          begin
            FChannels[15] := GorillaFMODAudioManager1.PlaySound(FClackSound);
            FChannels[15].Volume := LImpulse;
          end;
        end
        else
        begin
          FChannels[15] := GorillaFMODAudioManager1.PlaySound(FClackSound);
          FChannels[15].Volume := LImpulse;
        end;
      end
      else
      begin
        // regular ball with the index given by the argument
        if Assigned(FChannels[LTagIdx]) then
        begin
          if not FChannels[LTagIdx].IsPlaying then
          begin
            FChannels[LTagIdx] := GorillaFMODAudioManager1.PlaySound(FClackSound);
            FChannels[LTagIdx].Volume := LImpulse;
          end;
        end
        else
        begin
          FChannels[LTagIdx] := GorillaFMODAudioManager1.PlaySound(FClackSound);
          FChannels[LTagIdx].Volume := LImpulse;
        end;
      end;
    end);
end;

procedure TForm1.ResetBallOrigin(ABall : TGorillaSphere; APosition : TPoint3D);
var LPrefab : TGorillaColliderSettings;
begin
  // To stop the movement of the ball immediatly, we need to remove its
  // physics body and colliders
  GorillaPhysicsSystem1.RemoveCollider(ABall);

  // Afterwards we can re-position the ball
  ABall.Position.Point := APosition;
  ABall.ResetRotationAngle();

  // After it was placed at its new position, we can add a spherical collider
  // again.
  LPrefab := TGorillaColliderSettings.Create(TQ3BodyType.eDynamicBody);
  if ABall = WhiteBall then
  begin
    LPrefab.LinearDamping := 0.25;
    LPrefab.Data.Density  := 1;
    LPrefab.Data.Restitution := 0.5;
  end
  else
  begin
    LPrefab.LinearDamping := 0.25;
    LPrefab.Data.Density  := 0.5;
    LPrefab.Data.Restitution := 0.5;
  end;

  GorillaPhysicsSystem1.AddSphereCollider(ABall, LPrefab);
end;

function TForm1.BallsAvailable() : Boolean;
var I : Integer;
    LBody : TQ3Body;
begin
  Result := true;
  for I := Low(FBalls) to High(FBalls) do
  begin
    // If the "awake" flag is set in the body states - the ball is moving.
    // Caution: check if body is available! Maybe ball is getting resetted, then
    // it might not have a rigid body meanwhile or when a ball is out of game
    // it also has no rigid body anymore!
    LBody := FBalls[I].TagObject as TQ3Body;
    if Assigned(LBody) and (TQ3BodyState.eAwake in LBody.Flags) then
    begin
      Result := false;
      Exit;
    end;
  end;
end;

procedure TForm1.ActivateState();
begin
  Self.DirArrow.Visible := true;
  StateActive.Visible := true;
  StateWait.Visible := false;
  PowerPlane.SetVisibility(true);
end;

procedure TForm1.DeactivateState();
begin
  Self.DirArrow.Visible := false;
  StateActive.Visible := false;
  StateWait.Visible := true;
  PowerPlane.SetVisibility(false);
end;

procedure TForm1.ToggleAvailability();
begin
  if BallsAvailable() then
  begin
    // Shooting mode is enabled
    ActivateState();
  end
  else
  begin
    DeactivateState();
  end;
end;

procedure TForm1.GorillaPhysicsSystem1BeginContact(
  const AContact: PQ3ContactConstraint; const ABodyA, ABodyB: TQ3Body);
var LBodyBObj,
    LBodyAObj : TObject;
begin
  if not Assigned(AContact) then
    Exit;

  if not (Assigned(ABodyA) and Assigned(ABodyB)) then
    Exit;

  // Check for various states:
  LBodyAObj := TObject(ABodyA.GetFirstColliderPtr()^.UserData);
  LBodyBObj := TObject(ABodyB.GetFirstColliderPtr()^.UserData);
  
  // 1) billiard table collision can be ignored
  if (LBodyAObj = BilliardTable) or (LBodyBObj = BilliardTable) then
	Exit;
  
  // 2) ball-on-ball collision for sound playback
  // This comes first, because it's the most possible case
  // both other case cannot happen, if this happened
  if IsBall(LBodyAObj) and IsBall(LBodyBObj) then
  begin
//    Log.d('ball #%d and ball #%d collision',
//      [TFmxObject(LBodyAObj).Tag, TFmxObject(LBodyBObj).Tag]);

    PlayBallSound(TFmxObject(LBodyAObj).Tag - 1, ABodyA.LinearVelocity.Length);
    PlayBallSound(TFmxObject(LBodyBObj).Tag - 1, ABodyB.LinearVelocity.Length);
	
	// stop here - both other cases are not possible
	Exit;
  end;  

  // 3) ball in hole - Body A or B is a hole
  if IsHole(LBodyAObj) then
  begin
    // Body B is a ball?
    if IsBall(LBodyBObj) then
    begin
      Log.d('ball #%d in hole #%d',
        [TFmxObject(LBodyBObj).Tag, TFmxObject(LBodyAObj).Tag]);

      // Check if white ball to be reset to origin
      if (TFmxObject(LBodyBObj).Tag = 100) then
      begin
        ResetBallOrigin(LBodyBObj as TGorillaSphere, WHITEBALL_ORIGIN);
      end
      else
      begin
        // Mark ball as collected
        LockBallImage(TControl3D(LBodyBObj).Tag - 1);

        // Removing a collider is already threadsafe
        GorillaPhysicsSystem1.RemoveCollider(TControl3D(LBodyBObj));

        // When working with async physics, we need to synchronize visual actions
        TThread.Queue(nil,
          procedure()
          begin
            TGorillaSphere(LBodyBObj).SetVisibility(false);
          end);
      end;
    end;
  end
  else if IsHole(LBodyBObj) then
  begin
    // Body B is a ball?
    if IsBall(LBodyAObj) then
    begin
      Log.d('ball #%d in hole #%d',
        [TFmxObject(LBodyAObj).Tag, TFmxObject(LBodyBObj).Tag]);

      // Check if white ball to be reset to origin
      if (TFmxObject(LBodyAObj).Tag = 100) then
      begin
        ResetBallOrigin(LBodyAObj as TGorillaSphere, WHITEBALL_ORIGIN);
      end
      else
      begin
        // Mark ball as collected
        LockBallImage(TControl3D(LBodyAObj).Tag - 1);

        // Removing a collider is already threadsafe
        GorillaPhysicsSystem1.RemoveCollider(TControl3D(LBodyAObj));

        // When working with async physics, we need to synchronize visual actions
        TThread.Queue(nil,
          procedure()
          begin
            TGorillaSphere(LBodyAObj).SetVisibility(false);
          end);
      end;
    end;
  end;

  // 4) ball off the table
  if (LBodyAObj = Floor) then
  begin
    Log.d('ball #%d fell of the table', [TFmxObject(LBodyBObj).Tag]);

    // Reset ball to origin
    if (TFmxObject(LBodyBObj).Tag = 100) then
      ResetBallOrigin(LBodyBObj as TGorillaSphere, WHITEBALL_ORIGIN)
    else
      ResetBallOrigin(LBodyBObj as TGorillaSphere, FBallOrigins[TFmxObject(LBodyBObj).Tag]);

    PlayBallSound(TFmxObject(LBodyBObj).Tag - 1, ABodyB.LinearVelocity.Length);
  end
  else if (LBodyBObj = Floor) then
  begin
    Log.d('ball #%d fell of the table', [TFmxObject(LBodyAObj).Tag]);

    // Reset ball to origin
    if (TFmxObject(LBodyAObj).Tag = 100) then
      ResetBallOrigin(LBodyAObj as TGorillaSphere, WHITEBALL_ORIGIN)
    else
      ResetBallOrigin(LBodyAObj as TGorillaSphere, FBallOrigins[TFmxObject(LBodyAObj).Tag]);

    PlayBallSound(TFmxObject(LBodyAObj).Tag - 1, ABodyA.LinearVelocity.Length);
  end;
end;

procedure TForm1.GorillaViewport1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  // Store mouse shift state and mouse position
  // + activate: camera-rotation or shooting-mode
  FIsMouseDown := true;
  FMouseShift := Shift;
  FLastPos := PointF(X, Y);
end;

procedure TForm1.GorillaViewport1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
var LCurrent,
    LDiff  : TPointF;
    LHeight: Single;
begin
  // Get the current mouse position and calculate the difference to the previous
  // mouse position
  LCurrent := PointF(X, Y);
  LDiff    := FLastPos - LCurrent;

  if FIsMouseDown then
  begin
    if (ssLeft in Shift) and Self.DirArrow.Visible then
    begin
      // If left mouse button is down, we load up power but not adjust angle anymore
      DirArrow.BeginUpdate();
      try
        LHeight := DirArrow.Height + LDiff.Y * 0.1;
        LHeight := Min(10, Max(1, Abs(LHeight)));
        DirArrow.Height := LHeight;
      finally
        DirArrow.EndUpdate();
      end;
    end
    else if (ssRight in Shift) then
    begin
      // If right mouse button is down, rotate Camera around y-axis
      CameraTarget.RotationAngle.Y := CameraTarget.RotationAngle.Y - LDiff.X;
    end;
  end
  else
  begin
    // Only rotate the arrow if it's visible (shooting mode active)
    if Self.DirArrow.Visible then
    begin
      // If no mouse button is pressed, we just rotate the shooting direction
      ArrowOrient.RotationAngle.Y := ArrowOrient.RotationAngle.Y - LDiff.X;
    end;
  end;

  FLastPos := LCurrent;
end;

procedure TForm1.GorillaViewport1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var LAngles : TPoint3D;
begin
  // Check if left mouse button was down
  // If so, we should shoot into arrow direction
  if FIsMouseDown and (ssLeft in FMouseShift) and Self.DirArrow.Visible then
  begin
    // 1) Get the absolute angle of the arrow orientation
    LAngles := TTransformationMatrixUtils.GetEulerianAnglesFromTransformationMatrix(
      ArrowOrient.AbsoluteMatrix, TRotationOrder.EULER_XYZ
      );

    // 2) Compute the direction of arrow and power
    GorillaPhysicsSystem1.RemoteBodyImpulse(
      WhiteBall, GetNormalVector(LAngles.X) * DirArrow.Height * 3
      );
  end;

  // Deactivate shooting/camera-rotation mode
  FIsMouseDown := false;
  FMouseShift := [];
  FLastPos := PointF(X, Y);
  DirArrow.Height := 1;

  // Disable shooting mode if balls are moving
  ToggleAvailability();
end;

procedure TForm1.GorillaViewport1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
  // By mouse wheel we can zoom in/out to camera target
  if WheelDelta < 0 then
    GorillaCamera1.Position.Z := GorillaCamera1.Position.Z - 0.1
  else if WheelDelta > 0 then
    GorillaCamera1.Position.Z := GorillaCamera1.Position.Z + 0.1
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var LPos : TPoint3D;
begin
  // Check if shooting is available or not
  Inc(FToggleCheck);
  if (FToggleCheck mod 10 = 0) then
    ToggleAvailability();

  // Adjust camera to white ball position - due to tiny hills on billiard table
  // the camera jumps, which we don't want
  LPos := WhiteBall.Position.Point;
  LPos.Y := -3.75;
  CameraTarget.Position.Point := LPos;
end;

end.
