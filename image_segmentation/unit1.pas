unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtDlgs, StdCtrls,
  ExtCtrls, Buttons, ComCtrls, TAGraph, TAIntervalSources, TAChartImageList;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonSegmentasi: TButton;
    ButtonTepi: TButton;
    ButtonLoad: TButton;
    ButtonSave: TButton;
    GroupBoxSegmentasi: TGroupBox;
    Image1: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Label1: TLabel;
    Label2: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    Segmentasi: TStaticText;
    Segmentasi1: TStaticText;
    Segmentasi2: TStaticText;
    TextBiner: TStaticText;
    TextGrayscale: TStaticText;
    TextInput: TLabel;
    TextTepi: TLabel;
    TextWarna: TStaticText;
    procedure ButtonSegmentasiClick(Sender: TObject);
    procedure ButtonTepiClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);

    procedure Dilasi();
    procedure Erosi();
    procedure printBiner();
    procedure isiTepiBiner();   
    procedure isiTepiBinerMorph();
    procedure SegmentasiCitra();
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
  bitmapR, bitmapG, bitmapB, bitmapGray, bitmapGrayFilter, bitmapRedFilter, bitmapGreenFilter, bitmapBlueFilter, bitmapBiner, bitmapBinerMorph : array[-1..1000,-1..1000] of integer;
  TepiAtas, TepiBawah, TepiKiri, TepiKanan : integer;
  isMorphed : boolean = false;

procedure TForm1.ButtonLoadClick(Sender: TObject);
var
  j, i, ki, kj, r, g, b, gray, kRed, kGreen, kBlue : integer;
  smoothingFilter : array[0..2,0..2] of single = ((1/9,1/9,1/9),(1/9,1/9,1/9),(1/9,1/9,1/9));
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;

  image9.width := image1.width;
  image9.height := image1.height;

  image6.width := image1.width;
  image6.height := image1.height;

  image7.width := image1.width;
  image7.height := image1.height;

  image8.width := image1.width;
  image8.height := image1.height;

  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      //mengambil nilai RGB
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);

      gray := (R + G + B) div 3;
      bitmapR[i,j] := R;
      bitmapG[i,j] := G;
      bitmapB[i,j] := B;
      bitmapGray[i,j] := gray;

      // mengisi tepi image
      if (i = 0) or (j = 0) or (i = image1.width-1) or (j = image1.height-1) then
      begin
        if i = 0 then
        begin
          bitmapR[i-1,j] := bitmapR[i,j];
          bitmapG[i-1,j] := bitmapG[i,j];
          bitmapB[i-1,j] := bitmapB[i,j];
          bitmapGray[i-1,j] := bitmapGray[i,j];
        end;
        if j = 0 then
        begin
          bitmapR[i,j-1] := bitmapR[i,j];
          bitmapG[i,j-1] := bitmapG[i,j];
          bitmapB[i,j-1] := bitmapB[i,j];
          bitmapGray[i,j-1] := bitmapGray[i,j];
        end;
        if i = image1.width-1 then
        begin
          bitmapR[i+1,j] := bitmapR[i,j];
          bitmapG[i+1,j] := bitmapG[i,j];
          bitmapB[i+1,j] := bitmapB[i,j];
          bitmapGray[i+1,j] := bitmapGray[i,j];
        end;
        if j = image1.height-1 then
        begin
          bitmapR[i,j+1] := bitmapR[i,j];
          bitmapG[i,j+1] := bitmapG[i,j];
          bitmapB[i,j+1] := bitmapB[i,j];
          bitmapGray[i,j+1] := bitmapGray[i,j];
        end;
      end;

      image1.canvas.pixels[i,j] := RGB(bitmapR[i,j],bitmapG[i,j],bitmapB[i,j]);
    end;
  end;

  // blur  
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      kRed := 0;
      kGreen := 0;
      kBlue := 0;

      // filtering
      for ki:=0 to 2 do
      begin
        for kj:=0 to 2 do
        begin
          kRed := round(kRed + bitmapR[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
          kGreen := round(kGreen + bitmapG[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
          kBlue := round(kBlue + bitmapB[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
        end;
      end;

      bitmapRedFilter[i,j] := kRed;
      bitmapGreenFilter[i,j] := kGreen;
      bitmapBlueFilter[i,j] := kBlue;
    end;
  end;

  // grayscale
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      bitmapGrayFilter[i,j] := (bitmapRedFilter[i,j] + bitmapGreenFilter[i,j] + bitmapBlueFilter[i,j]) div 3;
    end;
  end;

  // output biner
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      if bitmapGrayFilter[i,j] > 127 then
      begin
        bitmapBiner[i,j] := 1;
      end
      else
      begin
        bitmapBiner[i,j] := 0;
      end;
    end;
  end;

  isiTepiBiner();
end;

procedure TForm1.ButtonSegmentasiClick(Sender: TObject);
var
  loopErosi, loopDilasi : integer;
begin
  for loopDilasi := 1 to 3 do
  begin
    Dilasi();
  end;

  for loopErosi := 1 to 3 do
  begin
    Erosi();
  end;

  for loopErosi := 1 to 2 do
  begin
    Erosi();
  end;

  for loopDilasi := 1 to 2 do
  begin
    Dilasi();
  end;

  SegmentasiCitra();

end;

procedure TForm1.ButtonTepiClick(Sender: TObject);
var
  i, j, ki, kj : integer;
  bitmapTepi, bitmapKontur : array[0..1000, 0..1000] of integer;
  kernelTepi : array[-1..1, -1..1] of integer = ((1,1,1),(1,-8,1),(1,1,1));
begin
  image5.height := image1.height;
  image5.width := image1.width;

  for i:=0 to image5.width do
  begin
    for j:=0 to image5.height do
    begin
      bitmapTepi[i,j] := 0;
      bitmapKontur[i,j] := 0;

      for ki:=-1 to 1 do
      begin
        for kj:=-1 to 1 do
        begin
          bitmapTepi[i,j] := round(bitmapTepi[i,j] + bitmapBinerMorph[i+ki,j+kj] * kernelTepi[ki,kj]);
          bitmapKontur[i,j] := round(bitmapKontur[i,j] + bitmapGray[i+ki,j+kj] * kernelTepi[ki,kj]);
        end;
      end;

      if bitmapTepi[i,j] < 0 then bitmapTepi[i,j] := 0;
      if bitmapTepi[i,j] > 1 then bitmapTepi[i,j] := 1;

      if bitmapKontur[i,j] < 0 then bitmapKontur[i,j] := 0;
      if bitmapKontur[i,j] > 255 then bitmapKontur[i,j] := 255;

      image5.canvas.pixels[i,j] := RGB(bitmapTepi[i,j]*255,bitmapTepi[i,j]*255,bitmapTepi[i,j]*255); 
      image8.canvas.pixels[i,j] := RGB(bitmapKontur[i,j],bitmapKontur[i,j],bitmapKontur[i,j]);
    end;
  end;

  for i:=0 to image5.width do
  begin
    for j:=0 to image5.height do
    begin

    end;
  end;
end;

procedure TForm1.Dilasi();
var
  i, j, kj, ki : integer;
  SE : array[-1..1,-1..1] of integer = ((0,0,0),(0,0,0),(0,0,0));
  temp : boolean;
begin
  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      temp := false;

      for kj:= -1 to 1 do
      begin
        for ki:= -1 to 1 do
        begin
          if isMorphed then
            temp := temp OR (bitmapBinerMorph[i+ki,j+kj] = SE[ki,kj])
          else
            temp := temp OR (bitmapBiner[i+ki,j+kj] = SE[ki,kj]);
        end;
      end;

      if temp then
        image9.canvas.pixels[i,j] := RGB(0,0,0)
      else
        image9.canvas.pixels[i,j] := RGB(255,255,255);
    end;
  end;

  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      if (getRValue(image9.canvas.pixels[i,j])+ getGValue(image9.canvas.pixels[i,j]) + getBValue(image9.canvas.pixels[i,j])) div 3 > 127 then
        bitmapBinerMorph[i,j] := 1
      else
        bitmapBinerMorph[i,j] := 0;
    end;
  end;

  if not isMorphed then isiTepiBinerMorph();

  printBiner();

  isMorphed := true;
end;

procedure TForm1.Erosi();
var
  i, j, kj, ki : integer;
  SE : array[-1..1,-1..1] of integer = ((0,0,0),(0,0,0),(0,0,0));
  temp : boolean;
begin
  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      temp := true;

      for kj:= -1 to 1 do
      begin
        for ki:= -1 to 1 do
        begin
          if isMorphed then
            temp := temp AND (bitmapBinerMorph[i+ki,j+kj] = SE[ki,kj])
          else
            temp := temp AND (bitmapBiner[i+ki,j+kj] = SE[ki,kj]);
        end;
      end;

      if temp then
        image9.canvas.pixels[i,j] := RGB(0,0,0)
      else
        image9.canvas.pixels[i,j] := RGB(255,255,255);
    end;
  end;

  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      if (getRValue(image9.canvas.pixels[i,j])+ getGValue(image9.canvas.pixels[i,j]) + getBValue(image9.canvas.pixels[i,j])) div 3 > 127 then
        bitmapBinerMorph[i,j] := 1
      else
        bitmapBinerMorph[i,j] := 0;
    end;
  end;

  if not isMorphed then isiTepiBinerMorph();

  printBiner();

  isMorphed := true;
end;

procedure TForm1.SegmentasiCitra();
var
  i, j : integer;
label
  labelatas, labelkanan, labelbawah, labelprint;
begin
//  tepi kiri
    for i:=0 to image1.Width-1 do
    begin
      for j:=0 to image1.Height-1 do
      begin
        if (bitmapBinerMorph[i,j] = 0) then
        begin
          tepikiri := i;
          goto labelatas;
        end;
      end;
    end;

//    tepi atas
    labelatas:
    for i:=0 to image1.width-1 do
    begin
      for j:=0 to image1.height-1 do
      begin
        if (bitmapBinerMorph[j,i] = 0) then
        begin
          tepiatas := i;
          goto labelkanan;
        end;
      end;
    end;

//    tepi kanan
    labelkanan:
    i:=image1.width-1;
    while i >= 0 do
    begin
      for j:=0 to image1.Height-1 do
      begin
        if (bitmapBinerMorph[i,j] = 0) then
        begin
          tepikanan := i;
          goto labelbawah;
        end;
      end;
      i := i-1;
    end;

    //  tepi bawah
    labelbawah:
    i:=image1.width-1;
    while i >= 0 do
    begin
      j:=image1.height-1;
      while j >= 0 do
      begin
        if (bitmapBinerMorph[i,j] = 0) then
        begin
          tepibawah := i;
          goto labelprint;
        end;
        j := j-1;
      end;
      i := i-1;
    end;

  labelprint:

  Image9.Canvas.Brush.Color := ClWhite;
  Image9.Canvas.FillRect(0, 0, Image9.Canvas.Width, Image9.Canvas.Height);
  Image9.Canvas.FillRect(0, 0, Image9.Canvas.Width, Image9.Canvas.Height);

  Image6.Canvas.Brush.Color := ClWhite;
  Image6.Canvas.FillRect(0, 0, Image9.Canvas.Width, Image9.Canvas.Height);
  Image6.Canvas.FillRect(0, 0, Image9.Canvas.Width, Image9.Canvas.Height);

  Image7.Canvas.Brush.Color := ClWhite;
  Image7.Canvas.FillRect(0, 0, Image9.Canvas.Width, Image9.Canvas.Height);
  Image7.Canvas.FillRect(0, 0, Image9.Canvas.Width, Image9.Canvas.Height);

  for i:=tepikiri to tepikanan do
  begin
    for j:=tepiatas to tepibawah do
    begin
      if bitmapBinerMorph[i,j] = 0 then
      begin
        image9.canvas.pixels[i,j] := RGB(bitmapR[i,j],bitmapG[i,j],bitmapB[i,j]);
        image6.canvas.pixels[i,j] := RGB(bitmapBinerMorph[i,j]*255,bitmapBinerMorph[i,j]*255,bitmapBinerMorph[i,j]*255);
        image7.canvas.pixels[i,j] := RGB(bitmapGray[i,j],bitmapGray[i,j],bitmapGray[i,j]);
      end;
    end;
  end;

  image9.Canvas.Pen.Color := clred;

  image9.Canvas.MoveTo(tepikiri, tepiatas);
  image9.Canvas.LineTo(tepikanan, tepiatas);

  image9.Canvas.MoveTo(tepikanan, tepiatas);
  image9.Canvas.LineTo(tepikanan, tepibawah);

  image9.Canvas.MoveTo(tepikanan, tepibawah);
  image9.Canvas.LineTo(tepikiri, tepibawah);

  image9.Canvas.MoveTo(tepikiri, tepibawah);
  image9.Canvas.LineTo(tepikiri, tepiatas);

  image6.Canvas.Pen.Color := clred;

  image6.Canvas.MoveTo(tepikiri, tepiatas);
  image6.Canvas.LineTo(tepikanan, tepiatas);

  image6.Canvas.MoveTo(tepikanan, tepiatas);
  image6.Canvas.LineTo(tepikanan, tepibawah);

  image6.Canvas.MoveTo(tepikanan, tepibawah);
  image6.Canvas.LineTo(tepikiri, tepibawah);

  image6.Canvas.MoveTo(tepikiri, tepibawah);
  image6.Canvas.LineTo(tepikiri, tepiatas);

  image7.Canvas.Pen.Color := clred;

  image7.Canvas.MoveTo(tepikiri, tepiatas);
  image7.Canvas.LineTo(tepikanan, tepiatas);

  image7.Canvas.MoveTo(tepikanan, tepiatas);
  image7.Canvas.LineTo(tepikanan, tepibawah);

  image7.Canvas.MoveTo(tepikanan, tepibawah);
  image7.Canvas.LineTo(tepikiri, tepibawah);

  image7.Canvas.MoveTo(tepikiri, tepibawah);
  image7.Canvas.LineTo(tepikiri, tepiatas);
end;

procedure TForm1.printBiner();
var
  i, j : integer;
begin
  for i:=0 to image9.width-1 do
  begin
    for j:=0 to image9.height-1 do
    begin
      image9.canvas.pixels[i,j] := RGB(bitmapBinerMorph[i,j]*255,bitmapBinerMorph[i,j]*255,bitmapBinerMorph[i,j]*255)
    end;
  end;
end;

procedure TForm1.isiTepiBiner();
var
  i, j : integer;
begin
  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      if i = 0 then bitmapBiner[i-1,j] := bitmapBiner[i,j];
      if j = 0 then bitmapBiner[i,j-1] := bitmapBiner[i,j];
      if i = image1.width-1 then bitmapBiner[i+1,j] := bitmapBiner[i,j];
      if j = image1.height-1 then bitmapBiner[i,j+1] := bitmapBiner[i,j];
    end;
  end;

//  mengisi sudut
  bitmapBiner[-1,-1] := 1;
  bitmapBiner[image1.width,-1] := 1;
  bitmapBiner[-1,image1.height] := 1;
  bitmapBiner[image1.width,image1.height] := 1;
end;

procedure TForm1.isiTepiBinerMorph();
var
  i, j : integer;
begin
  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      if i = 0 then bitmapBinerMorph[i-1,j] := 1;
      if j = 0 then bitmapBinerMorph[i,j-1] := 1;
      if i = image1.width-1 then bitmapBinerMorph[i+1,j] := 1;
      if j = image1.height-1 then bitmapBinerMorph[i,j+1] := 1;
    end;
  end;

//  mengisi sudut
  bitmapBinerMorph[-1,-1] := 1;
  bitmapBinerMorph[image1.width,-1] := 1;
  bitmapBinerMorph[-1,image1.height] := 1;
  bitmapBinerMorph[image1.width,image1.height] := 1;
end;

end.

