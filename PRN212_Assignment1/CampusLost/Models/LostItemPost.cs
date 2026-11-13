using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace CampusLost.Models;

public class LostItemPost
{
    public int Id { get; set; }

    [Required(ErrorMessage = "Hãy nhập tên đồ vật.")]
    [StringLength(100, ErrorMessage = "Tên đồ vật tối đa 100 ký tự.")]
    public string Title { get; set; } = string.Empty;

    // 1: Bị mất; 2: Nhặt được (CK_Posts_Kind).
    [BindRequired]
    [Range(1, 2, ErrorMessage = "Hãy chọn Bị mất hoặc Nhặt được.")]
    public int Kind { get; set; } = 1;

    [Required(ErrorMessage = "Hãy nhập địa điểm.")]
    [StringLength(120, ErrorMessage = "Địa điểm tối đa 120 ký tự.")]
    public string Location { get; set; } = string.Empty;

    [Required(ErrorMessage = "Hãy nhập mô tả.")]
    [StringLength(500, ErrorMessage = "Mô tả tối đa 500 ký tự.")]
    public string Description { get; set; } = string.Empty;

    [Required(ErrorMessage = "Hãy nhập thông tin liên hệ.")]
    [StringLength(120, ErrorMessage = "Thông tin liên hệ tối đa 120 ký tự.")]
    public string Contact { get; set; } = string.Empty;

    public DateTime PostedOn { get; set; }
}
