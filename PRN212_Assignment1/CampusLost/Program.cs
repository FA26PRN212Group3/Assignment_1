using CampusLost.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllersWithViews();
builder.Services.AddDbContext<CampusLostDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("CampusLostDb")
        ?? throw new InvalidOperationException("Missing connection string 'CampusLostDb'.")));

var app = builder.Build();
app.UseRouting();
app.MapControllerRoute(name: "default", pattern: "{controller=Posts}/{action=Index}/{id?}");
app.Run();
