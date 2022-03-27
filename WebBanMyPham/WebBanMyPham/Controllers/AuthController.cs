using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;

namespace WebBanMyPham.Controllers
{
    public class AuthController : Controller
    {
        //
        // GET: /Auth/
        DatabaseDataContext db = new DatabaseDataContext();
        public ActionResult DangNhap()
        {
            return View();
        }

        [HttpPost]
        public ActionResult DangNhap(FormCollection f)
        {
            string user = f["username"].ToString();
            string pw = f["pw"].ToString();

            // kiểm tra rỗng
            if (user.Trim().Length == 0 || pw.Trim().Length == 0)
            {
                ViewBag.Message = "Vui lòng nhập đủ thông tin";
                ViewBag.Info = "Empty";

                return View();
            }

            // ck trong db
            List<sp_CKAccResult> a = db.sp_CKAcc(user.Trim(), pw.Trim(), "Khách Hàng").ToList();
            string msg = a[0].Message;

            if (msg.Equals("SUCCESS"))
            {
                // lấy id tài khoản
                TAIKHOAN tk_ = db.TAIKHOANs.Single(tk => tk.USERNAME==user && tk.ID_GR==3);
                THONGTINTAIKHOAN ttnd_ = db.THONGTINTAIKHOANs.Single(ttnd => ttnd.ID_TAIKHOAN == tk_.ID);
                Session["ThongTinNguoiDung"] = new ThongTinNguoiDung { Tk = new TaiKhoan { Username=tk_.USERNAME }, HoTen=ttnd_.HOTEN };
                return RedirectToAction("Index", "Home");
            }

            ViewBag.Message = msg;
            ViewBag.Info = "incorrect";

            return View();
        }

        [HttpPost]
        public JsonResult DangKy(ThongTinNguoiDung signup)
        {
            string res = db.sp_AddAcc(signup.Tk.Username, signup.Tk.Pw, "Khách Hàng", signup.HoTen, signup.NgaySinh, signup.GioiTinh, signup.Email, signup.Sdt, string.Empty).ToList<sp_AddAccResult>()[0].Message;

            JsonResult a = new JsonResult();

            if (res.Equals("Username đã tồn tại."))
                a.Data = "username";
            else if (res.Equals("SUCCESS"))
                a.Data = "Success";
            else a.Data = "fail";

            return a;
        }
    }
}
