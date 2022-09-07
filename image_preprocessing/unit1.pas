unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtDlgs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonLoad: TButton;
    ButtonSave: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
uses
  windows;

var
  bitmapR, bitmapG, bitmapB, bitmapGray, bitmapbiner : array[-2..1000,-2..1000] of integer;

procedure TForm1.ButtonLoadClick(Sender: TObject);
                             
var
  j, i, ki, kj, r, g, b, gray, kRed, kGreen, kBlue, kGray, kBiner : integer;
  smoothingKernel : Array [1..5,1..5] of integer = (
                  (2,4,5,4,2),
                  (4,9,12,9,4),
                  (5,12,15,12,5),
                  (4,9,12,9,4),
                  (2,4,5,4,2)
  );

begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;                              

  image2.Width :=image1.width;
  image2.height:=image1.height;

  for j:=0 to image1.Height-1 do
  begin
    for i:=0 to image1.Width-1 do
    begin
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);
      gray := (R + G + B) div 3;
      bitmapR[i,j] := R;
      bitmapG[i,j] := G;
      bitmapB[i,j] := B;
      bitmapGray[i,j] := gray;

      if (i = 0) or (j = 0) or (i = image1.width-1) or (j = image1.height-1) then
      begin
        if i = 0 then
        begin
          bitmapR[i-1,j] := bitmapR[i,j];
          bitmapR[i-2,j] := bitmapR[i,j];
          bitmapG[i-1,j] := bitmapG[i,j];
          bitmapG[i-2,j] := bitmapG[i,j];
          bitmapB[i-1,j] := bitmapB[i,j]; 
          bitmapB[i-2,j] := bitmapB[i,j];
          bitmapGray[i-1,j] := bitmapGray[i,j]; 
          bitmapGray[i-2,j] := bitmapGray[i,j];
        end;
        if j = 0 then
        begin
          bitmapR[i,j-1] := bitmapR[i,j];  
          bitmapR[i,j-2] := bitmapR[i,j];
          bitmapG[i,j-1] := bitmapG[i,j];  
          bitmapG[i,j-2] := bitmapG[i,j];
          bitmapB[i,j-1] := bitmapB[i,j];  
          bitmapB[i,j-2] := bitmapB[i,j];
          bitmapGray[i,j-1] := bitmapGray[i,j];
          bitmapGray[i,j-2] := bitmapGray[i,j];
        end;
        if i = image1.width-1 then
        begin
          bitmapR[i+1,j] := bitmapR[i,j];  
          bitmapR[i+2,j] := bitmapR[i,j];
          bitmapG[i+1,j] := bitmapG[i,j]; 
          bitmapG[i+2,j] := bitmapG[i,j];
          bitmapB[i+1,j] := bitmapB[i,j];  
          bitmapB[i+2,j] := bitmapB[i,j];
          bitmapGray[i+1,j] := bitmapGray[i,j];  
          bitmapGray[i+2,j] := bitmapGray[i,j];
        end;
        if j = image1.height-1 then
        begin
          bitmapR[i,j+1] := bitmapR[i,j]; 
          bitmapR[i,j+2] := bitmapR[i,j];
          bitmapG[i,j+1] := bitmapG[i,j];  
          bitmapG[i,j+2] := bitmapG[i,j];
          bitmapB[i,j+1] := bitmapB[i,j];    
          bitmapB[i,j+2] := bitmapB[i,j];
          bitmapGray[i,j+1] := bitmapGray[i,j]; 
          bitmapGray[i,j+2] := bitmapGray[i,j];
        end;
      end;

      Image1.canvas.pixels[i,j] := RGB(bitmapR[i,j],bitmapG[i,j],bitmapB[i,j]);

      if (gray > 127) then bitmapBiner[i,j] := 1 else bitmapBiner[i,j] := 0;

      Image2.canvas.pixels[i,j] := RGB(bitmapBiner[i,j] * 255, bitmapBiner[i,j] * 255, bitmapBiner[i,j] * 255);
    end;
  end;

  for i:=0 to Image1.width-1 do
  begin
    for j:=0 to Image1.height-1 do
    begin
      kGray := 0;
      kRed := 0;
      kGreen := 0;
      kBlue := 0;
      kBiner := 0;

      for ki:=1 to 5 do
      begin
        for kj:=1 to 5 do
        begin
          kGray := round(kGray + bitmapGray[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kRed := round(kRed + bitmapR[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kGreen := round(kGreen + bitmapG[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kBlue := round(kBlue + bitmapB[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
          kBiner := round(kBiner + bitmapBiner[i+ki-1,j+kj-1] * smoothingKernel[ki,kj]);
        end;
      end;

      kGray := round(kGray/159);
      kRed := round(kRed/159);
      kGreen := round(kGreen/159);
      kBlue := round(kBlue/159);
      kBiner := round(kBiner/159);

      if kGray > 255 then kGray := 255;
      if kGray < 0 then kGray := 0;

      if kRed > 255 then kRed := 255;
      if kRed < 0 then kRed := 0;

      if kGreen > 255 then kGreen := 255;
      if kGreen < 0 then kGreen := 0;

      if kBlue > 255 then kBlue := 255;
      if kBlue < 0 then kBlue := 0;

      if kBiner > 255 then kBiner := 255;
      if kBiner < 0 then kBiner := 0;

      Image3.canvas.pixels[i,j] := RGB(kRed,kGreen,kBlue);
      Image4.canvas.pixels[i,j] := RGB(kGray,kGray,kGray);
      Image5.canvas.pixels[i,j] := RGB(kBiner*255,kBiner*255,kBiner*255);
    end;
  end;
end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
begin
  if (SavePictureDialog1.Execute) then
  begin
    image2.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

end.

