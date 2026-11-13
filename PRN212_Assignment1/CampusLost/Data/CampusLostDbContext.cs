using CampusLost.Models;
using Microsoft.EntityFrameworkCore;

namespace CampusLost.Data;

public class CampusLostDbContext(DbContextOptions<CampusLostDbContext> options) : DbContext(options)
{
    public DbSet<LostItemPost> Posts => Set<LostItemPost>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var post = modelBuilder.Entity<LostItemPost>();
        post.ToTable("Posts", "dbo");
        post.HasKey(p => p.Id).HasName("PK_Posts");
        post.Property(p => p.Id).UseIdentityColumn();
        post.Property(p => p.Title).HasMaxLength(100).UseCollation("Vietnamese_CI_AS").IsRequired();
        post.Property(p => p.Kind).IsRequired();
        post.Property(p => p.Location).HasMaxLength(120).IsRequired();
        post.Property(p => p.Description).HasMaxLength(500).IsRequired();
        post.Property(p => p.Contact).HasMaxLength(120).IsRequired();
        post.Property(p => p.PostedOn)
            .HasColumnType("datetime2(0)")
            .HasDefaultValueSql("SYSUTCDATETIME()")
            .ValueGeneratedOnAdd()
            // SQL datetime2 has no time-zone marker; values in this column are UTC.
            .HasConversion(value => value, value => DateTime.SpecifyKind(value, DateTimeKind.Utc));
        post.HasIndex(p => new { p.PostedOn, p.Id })
            .IsDescending(true, true)
            .HasDatabaseName("IX_Posts_PostedOn_Id");
    }
}
