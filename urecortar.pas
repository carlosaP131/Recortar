unit urecortar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ExtDlgs, Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure Button1Click(Sender: TObject);

    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1Paint(Sender: TObject);
  private
    procedure CropImage; // Método privado para recortar la imagen
  public
  end;

var
  Form1: TForm1;
  StartPoint, EndPoint: TPoint;
  IsSelecting: Boolean;

implementation

{$R *.lfm}

{ TForm1 }

// Botón para cargar la imagen
procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    Image1.Stretch := False; // Asegúrate de no distorsionar la imagen
    IsSelecting := False;    // Reinicia la selección
  end;
end;

// Inicio de la selección
procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(Image1.Picture.Bitmap) then
  begin
    IsSelecting := True;
    StartPoint := Point(X, Y);
  end;
end;

// Seguimiento de la selección
procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if IsSelecting then
  begin
    EndPoint := Point(X, Y);
    Image1.Repaint;
  end;
end;

// Finalización de la selección y recorte automático
procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if IsSelecting then
  begin
    IsSelecting := False;
    EndPoint := Point(X, Y);
    CropImage; // Llama al método de recorte
  end;
end;

// Dibujar el área seleccionada
procedure TForm1.Image1Paint(Sender: TObject);
begin
  if IsSelecting then
  begin
    with Image1.Canvas do
    begin
      Pen.Color := clRed;
      Pen.Style := psDot;
      Brush.Style := bsClear;
      Rectangle(StartPoint.X, StartPoint.Y, EndPoint.X, EndPoint.Y);
    end;
  end;
end;

// Método para recortar la imagen
procedure TForm1.CropImage;
var
  CropRect: TRect;
  CroppedBitmap: TBitmap;
begin
  if not Assigned(Image1.Picture.Bitmap) then Exit;

  // Asegúrate de que los puntos están dentro de la imagen
  CropRect := Rect(
    Max(0, Min(StartPoint.X, EndPoint.X)),
    Max(0, Min(StartPoint.Y, EndPoint.Y)),
    Min(Image1.Picture.Width, Max(StartPoint.X, EndPoint.X)),
    Min(Image1.Picture.Height, Max(StartPoint.Y, EndPoint.Y))
  );

  // Valida que el área no sea vacía
  if (CropRect.Width > 0) and (CropRect.Height > 0) then
  begin
    CroppedBitmap := TBitmap.Create;
    try
      CroppedBitmap.Width := CropRect.Width;
      CroppedBitmap.Height := CropRect.Height;

      CroppedBitmap.Canvas.CopyRect(
        Rect(0, 0, CroppedBitmap.Width, CroppedBitmap.Height),
        Image1.Picture.Bitmap.Canvas, CropRect
      );

      // Asigna la imagen recortada al componente
      Image1.Picture.Bitmap.Assign(CroppedBitmap);
    finally
      CroppedBitmap.Free;
    end;
  end
  else
    ShowMessage('Área de recorte no válida.');
end;

end.

