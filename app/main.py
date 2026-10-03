from fastapi import FastAPI, Depends, HTTPException, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from .database.db import engine, SessionLocal, Base
from .database import models
from pydantic import BaseModel
from typing import List
import urllib.parse
import csv
import io

Base.metadata.create_all(bind=engine)

app = FastAPI()
templates = Jinja2Templates(directory="app/templates")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

class GameyaCreate(BaseModel):
    name: str
    total_amount: float
    monthly_installment: float
    total_months: int

class MemberShareCreate(BaseModel):
    gameya_id: int
    share_group_id: int
    member_name: str
    phone: str
    share_ratio: float
    payout_month: int

class InstallmentUpdate(BaseModel):
    gameya_id: int
    member_id: int
    month_number: int
    status: str

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/gameyas/")
def create_gameya(gameya: GameyaCreate, db: Session = Depends(get_db)):
    db_gameya = models.Gameya(**gameya.dict())
    db.add(db_gameya)
    db.commit()
    db.refresh(db_gameya)
    return db_gameya

@app.post("/members/")
def add_member(member: MemberShareCreate, db: Session = Depends(get_db)):
    gameya = db.query(models.Gameya).filter(models.Gameya.id == member.gameya_id).first()
    if not gameya:
        raise HTTPException(status_code=404, detail="Gameya not found")
        
    db_member = models.MemberShare(**member.dict())
    db.add(db_member)
    db.commit()
    db.refresh(db_member)
    return db_member

@app.post("/installments/")
def update_installment(update: InstallmentUpdate, db: Session = Depends(get_db)):
    installment = db.query(models.Installment).filter(
        models.Installment.gameya_id == update.gameya_id,
        models.Installment.member_id == update.member_id,
        models.Installment.month_number == update.month_number
    ).first()
    
    if not installment:
        installment = models.Installment(**update.dict())
        db.add(installment)
    else:
        installment.status = update.status
        
    db.commit()
    db.refresh(installment)
    return installment

@app.get("/whatsapp/{member_id}/{month_number}")
def generate_whatsapp_link(member_id: int, month_number: int, db: Session = Depends(get_db)):
    member = db.query(models.MemberShare).filter(models.MemberShare.id == member_id).first()
    if not member:
        raise HTTPException(status_code=404, detail="Member not found")
        
    gameya = db.query(models.Gameya).filter(models.Gameya.id == member.gameya_id).first()
    
    msg = f"أهلاً {member.member_name}، نذكرك بموعد قسط الجمعية {gameya.name} الخاص بشهر {month_number}. القيمة المطلوبة: {member.share_ratio}."
    encoded_msg = urllib.parse.quote(msg)
    return {"whatsapp_link": f"https://wa.me/{member.phone}?text={encoded_msg}"}

@app.get("/export/{gameya_id}/csv")
def export_csv(gameya_id: int, db: Session = Depends(get_db)):
    members = db.query(models.MemberShare).filter(models.MemberShare.gameya_id == gameya_id).all()
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["Name", "Phone", "Share Ratio", "Payout Month"])
    for m in members:
        writer.writerow([m.member_name, m.phone, m.share_ratio, m.payout_month])
    return JSONResponse(content={"csv_data": output.getvalue()})
