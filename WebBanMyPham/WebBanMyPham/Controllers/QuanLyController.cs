using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;

namespace WebBanMyPham.Controllers
{
    public class QuanLyController : Controller
    {
        //
        // GET: /QuanLy/
        DatabaseDataContext db = new DatabaseDataContext();

        public ActionResult HoaDon()
        {
            if (Session["ThongTinAdmin"] == null)
                return RedirectToAction("Index", "Admin");

            List<HoaDon> lstHoaDon = db.HOADONs.Select(hd => new HoaDon
            {
                TenKH = db.THONGTINTAIKHOANs.Single(tttk => tttk.ID_TAIKHOAN == hd.KHACHHANG.TAIKHOAN.ID).HOTEN,
                Gia = hd.DONGIA.Value,
                NgayCapNhat = hd.NGTAO.Value
            }).ToList();

            ViewBag.TongThanhTien = lstHoaDon.Sum(hd => hd.Gia);

            return View(lstHoaDon);
        }
        public ActionResult QLTaiKhoan()
        {
            if (Session["ThongTinAdmin"] == null)
                return RedirectToAction("Index", "Admin");

            List<ThongTinNguoiDung> lstTK = db.TAIKHOANs.Join(
                db.THONGTINTAIKHOANs,
                tk => tk.ID,
                tttk => tttk.ID_TAIKHOAN,
                (tk, tttk) => new ThongTinNguoiDung()
                {
                    HoTen = tttk.HOTEN,
                    Email = tttk.EMAIL,
                    Tk = new TaiKhoan { Username = tk.USERNAME, Pw = tk.PW.ToString(), Id_TK = tk.ID, Id_gr = tk.ID_GR.Value },
                    Sdt = tttk.SDT,
                    GioiTinh = tttk.GTINH.Value ? "Nam" : "Nữ",
                    NgaySinh = tttk.NGSINH.Value
                }).Where(tk => tk.Tk.Id_gr == 3).ToList();


            return View(lstTK);
        }

        [HttpPost]
        public ActionResult QLTaiKhoan(string txtUserName)
        {
            if (Session["ThongTinAdmin"] == null)
                return RedirectToAction("Index", "Admin");

            if (string.IsNullOrEmpty(txtUserName))
                return RedirectToAction("QLTaiKhoan");

            List<ThongTinNguoiDung> lstTK = db.TAIKHOANs.Join(
                db.THONGTINTAIKHOANs,
                tk => tk.ID,
                tttk => tttk.ID_TAIKHOAN,
                (tk, tttk) => new ThongTinNguoiDung()
                {
                    HoTen = tttk.HOTEN,
                    Email = tttk.EMAIL,
                    Tk = new TaiKhoan { Username = tk.USERNAME, Pw = tk.PW.ToString(), Id_TK = tk.ID, Id_gr = tk.ID_GR.Value },
                    Sdt = tttk.SDT,
                    GioiTinh = tttk.GTINH.Value ? "Nam" : "Nữ",
                    NgaySinh = tttk.NGSINH.Value
                }).Where(tk => tk.Tk.Id_gr == 3 && tk.Tk.Username==txtUserName).ToList();


            return View(lstTK);
        }

        public ActionResult CapNhatTaiKhoan(string username, FormCollection f)
        {
            if (Session["ThongTinAdmin"] == null)
                return RedirectToAction("Index", "Admin");

            // cập nhật trên db
            List<sp_ChangeAccResult> rs = db.sp_ChangeAcc(username, f["txtPW"].ToString(), "Khách Hàng").ToList();

            if (rs[0].Message.Equals("SUCCESS"))
            {
                Session["Message"] = "Cập nhật thành công";
                Session["Info"] = "SUCCESS";
            }
            else
            {
                Session["Message"] = rs[0].Message;
                Session["Info"] = "err";
            }

            return RedirectToAction("QLTaiKhoan");
        }

    }
}
